////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2009 Tyler Wright, Robert Taylor, Jacob Wright
//	
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//	
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package flight.domain
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import flight.commands.IAsyncCommand;
	import flight.commands.ICommand;
	import flight.commands.ICommandFactory;
	import flight.commands.ICommandInvoker;
	import flight.errors.CommandError;
	import flight.events.DomainEvent;
	import flight.net.IResponse;
	import flight.net.Response;
	import flight.utils.Registry;
	import flight.utils.Type;
	import flight.utils.getClassName;
	import flight.utils.getType;
	
	import mx.core.IMXMLObject;
	
	/**
	 * Domain acts as an interface to a CommandHistory.
	 * It exposes methods such as undo/redo and routes IUndoableCommands to the current history.  
	 */
	public class DomainController implements IEventDispatcher, ICommandInvoker, ICommandFactory, IMXMLObject
	{
		protected var _invoker:ICommandInvoker;
		
		/**
		 * Associative array of command classes organized by their designated type.
		 */
		protected var commandClasses:Array = [];
		
		/**
		 * Stores each command's type for dispatching.
		 */
		protected var typesByCommand:Dictionary = new Dictionary(true);
		
		protected var eventDispatcher:EventDispatcher;
		
		protected var asyncExecutions:Dictionary = new Dictionary();		// keeps a strong reference to each IAsyncCommand until completed or canceled
		protected var executing:Dictionary = new Dictionary();				// the type of the currently executing script, used to avoid unwanted recursion
		protected var response:IResponse;
		
		
		public function get type():Class
		{
			return getType(this);
		}
		
		protected function get invoker():ICommandInvoker
		{
			return _invoker;
		}
		protected function set invoker(value:ICommandInvoker):void
		{
			_invoker = value;
		}
		
		/**
		 * Set up this object.
		 */
		protected function initController():void
		{
		}
		
		/**
		 * Allows DomainController to be created in MXML in several places but
		 * refer to the same instance.
		 */
		public function initialized(document:Object, id:String):void
		{
			var type:Class = getType(this);
			var instance:Object = Registry.lookup(type);
			if (instance) {
				document[id] = instance
			} else {
				Registry.register(type, this);
				// set up commands or do whatever you might want to do in the
				// constructor but shouldn't since the object might be throw-away
				initController(); 
			}
		}
		
		/**
		 * Registers a command class with a unique id for later access.
		 */
		public function addCommand(type:String, commandClass:Class):void
		{
			delete typesByCommand[ commandClasses[type] ];
			commandClasses[type] = commandClass;
			typesByCommand[commandClass] = type;
		}
		
		/**
		 * Registers a command class with a unique id for later access.
		 */
		public function addCommands(commandIndex:Object):void
		{
			for(var i:String in commandIndex)
			{
				var command:ICommand = commandIndex[i] as ICommand;
				if(command != null) {
					addCommand(i, getType(command));
				}
			}
		}
		
		/**
		 * Retrieves the command class registered with this type.
		 */
		public function getCommand(type:String):Class
		{
			return commandClasses[type];
		}
		
		public function getCommandType(command:Object):String
		{
			if( !(command is Class) ) {
				command = getType(command);
			}
			return typesByCommand[command];
		}
		
		/**
		 * Primary method responsible for command class instantiation, hiding the details
		 * of class inheritance, implementation, origin, etc.
		 */
		public function createCommand(type:String, properties:Object = null):ICommand
		{
			var commandClass:Class = getCommand(type);
			if(commandClass == null) {
				return null;
			}
			
			var command:ICommand = new commandClass() as ICommand;
			if(command == null) {
				throw new Error("Command " + getClassName(commandClass) + " is not of type ICommand.");
			}
			
			if("client" in command) {
				var clientClass:Class = Type.getPropertyType(command, "client");
				command["client"] = (this is clientClass ? this : new clientClass());
			}
			
			
			for(var i:String in properties) {
				if(i in command) {
					command[i] = properties[i];
				}
			}
			
			if(properties is Array) {
				var list:Array = getArgumentList(command);
				for(i in list) {
					if(i in properties) {
						command[ list[i] ] = properties[i];
					}
				}
			}
			
			return command;
		}
		
		public function dispatchResponse(type:String, response:IResponse):void
		{
			if(willTrigger(type)) {
				dispatchEvent( new DomainEvent(type, response) );
			}
		}
		
		/**
		 * Primary method for invoking commands in the Domain class.
		 */
		public function execute(type:String, properties:Object = null):IResponse
		{
			if(!executing[type]) {
				executing[type] = true;
				response = null;
				
				var command:ICommand = createCommand(type, properties);
				
				if(command != null) {
					executeCommand(command);
				} else {
					executeScript(type, properties);
				}
				
				executing[type] = false;
				return response;
			}
			return null;
		}
		
		/**
		 * Receives an ICommand instance ready for execution and returns its success or failure.
		 */
		public function executeCommand(command:ICommand):void
		{
			if(command == null) {
				return;
			}
			
			if(command is IAsyncCommand) {
				registerAsyncCommand(command as IAsyncCommand);
			}
			
			try {
				if(invoker != null) {
					invoker.executeCommand(command);
				} else {
					command.execute();
				}
				
				if(command is IAsyncCommand) {
					response = IAsyncCommand(command).response;
				} else {
					response = new Response().complete(command);		// stored here for return from DomainController.execute()
					dispatchResponse(getCommandType(command), response);
				}
			} catch(error:CommandError) {
				if(command is IAsyncCommand) {
					releaseAsyncCommand(command as IAsyncCommand);
				}
				response = new Response().cancel(error)
				dispatchResponse(getCommandType(command), response);
			}
		}
		
		protected function executeScript(type:String, params:Object = null):void
		{
			if( !(type in this && this[type] is Function) ) {
				return;
			}
			
			var script:Function = this[type];
			var result:Object = (params != null && params.length > 0) ?
								script.apply(null, [].concat(params)) :
								script();
			
			response = (result is IResponse) ? result as IResponse : new Response().complete(result);
			dispatchResponse(type, response);
		}
		
		protected function registerAsyncCommand(command:IAsyncCommand):void
		{
			asyncExecutions[command] = true;
			command.addEventListener(Event.COMPLETE, onAsyncEvent);
			command.addEventListener(Event.CANCEL, onAsyncEvent);
		}
		
		protected function releaseAsyncCommand(command:IAsyncCommand):void
		{
			command.removeEventListener(Event.COMPLETE, onAsyncEvent);
			command.removeEventListener(Event.CANCEL, onAsyncEvent);
			delete asyncExecutions[command];
		}
		
		/**
		 * Catches asynchronous commands upon completion and dispatches an event.
		 */
		private function onAsyncEvent(event:Event):void
		{
			var asyncCommand:IAsyncCommand = event.target as IAsyncCommand;
			releaseAsyncCommand(asyncCommand);
			dispatchResponse(getCommandType(asyncCommand), asyncCommand.response);
		}
		
		private static function getArgumentList(command:ICommand):Array
		{
			var list:Array = [];
			
			var argumentList:XMLList = Type.describeProperties(command, "Argument");
			for each(var argument:XML in argumentList) {
				if(argument.metadata.(@name == "Argument").arg.@value.length() > 0) {
					list[argument.metadata.(@name == "Argument").arg.@value] = argument.@name;
				}
			}
			return list;
		}
		
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if(eventDispatcher == null) {
				eventDispatcher = new EventDispatcher(this);
			}
			
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if(eventDispatcher != null) {
				eventDispatcher.removeEventListener(type, listener, useCapture);
			}
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			if(eventDispatcher != null && eventDispatcher.hasEventListener(event.type)) {
				return eventDispatcher.dispatchEvent(event);
			}
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			if(eventDispatcher != null) {
				return eventDispatcher.hasEventListener(type);
			}
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			if(eventDispatcher != null) {
				return eventDispatcher.willTrigger(type);
			}
			return false;
		}
		
	}
}


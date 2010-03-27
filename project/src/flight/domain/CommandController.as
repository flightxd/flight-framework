////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2009 Tyler Wright, Robert Taylor, Jacob Wright
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package flight.domain
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import flight.commands.IAsyncCommand;
	import flight.commands.ICommand;
	import flight.commands.ICommandFactory;
	import flight.commands.ICommandInvoker;
	import flight.errors.CommandError;
	import flight.events.ControllerEvent;
	import flight.net.IResponse;
	import flight.net.Response;
	import flight.utils.ObjectEditor;
	import flight.utils.getClassName;
	import flight.utils.getType;
	import flight.utils.ValueObject;
	
	/**
	 *   
	 */
	public class CommandController extends ValueObject implements ICommandInvoker, ICommandFactory
	{
		protected var invoker:ICommandInvoker;
		
		/**
		 * Associative array of command classes organized by their designated type.
		 */
		private var commandClasses:Array = [];
		private var propertyIndex:Array = [];
		
		/**
		 * Stores each command's type for dispatching.
		 */
		private var typesByCommand:Dictionary = new Dictionary(true);
		
		private var asyncExecutions:Dictionary = new Dictionary();			// keeps a strong reference to each IAsyncCommand until completed or canceled
		private var executing:Dictionary = new Dictionary();				// the type of the currently executing script, used to avoid unwanted recursion
		private var response:IResponse;
		
		/**
		 * Registers a command class with a unique id for later access.
		 */
		public function addCommand(type:String, commandClass:Class, propertyList:Array = null):void
		{
			delete typesByCommand[ commandClasses[type] ];
			commandClasses[type] = commandClass;
			propertyIndex[type] = propertyList;
			typesByCommand[commandClass] = type;
		}
		
		/**
		 * Registers a command class with a unique id for later access.
		 */
		public function addCommands(commandIndex:Object):void
		{
			for (var i:String in commandIndex)
			{
				var command:ICommand = commandIndex[i] as ICommand;
				if (command != null) {
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
			if ( !(command is Class) ) {
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
			if (commandClass == null) {
				return null;
			}
			
			var command:ICommand = new commandClass() as ICommand;
			if (command == null) {
				throw new Error("Command " + getClassName(commandClass) + " is not of type ICommand.");
			}
			
			if (properties != null) {
				ObjectEditor.merge(properties, command);
				
				var propertyList:Array = propertyIndex[type];
				if (properties is Array && propertyList != null) {
					for (var i:int = 0; i < properties.length; i++) {
						var property:String = propertyList[i];
						command[property] = properties[i];
					}
				}
			}
			
			return command;
		}
		
		/**
		 * Primary method for invoking commands in the CommandController class.
		 */
		public function execute(type:String, properties:Object = null):IResponse
		{
			if (!executing[type]) {
				executing[type] = true;
				response = null;
				
				var command:ICommand = createCommand(type, properties);
				
				if (command != null) {
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
			if (command == null) {
				return;
			}
			
			if (command is IAsyncCommand) {
				registerAsyncCommand(command as IAsyncCommand);
			}
			
			try {
				if (invoker != null) {
					invoker.executeCommand(command);
				} else {
					command.execute();
				}
				
				if (command is IAsyncCommand) {
					response = IAsyncCommand(command).response;
				} else {
					dispatchResponse(getCommandType(command), new Response(command));
				}
			} catch (error:CommandError) {
				if (command is IAsyncCommand) {
					releaseAsyncCommand(command as IAsyncCommand);
				}
				dispatchResponse(getCommandType(command), new Response(error));
			}
		}
		
		protected function executeScript(type:String, params:Object = null):void
		{
			if ( !(type in this && this[type] is Function) ) {
				return;
			}
			response = null;
			
			var script:Function = this[type];
			var result:Object = params != null ?
								script.apply(null, [].concat(params)) :
								script();
			
			if (response == null) {
				response = (result is IResponse) ? result as IResponse : new Response(result);
				dispatchResponse(type, response);
			}
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
		
		protected function dispatchResponse(type:String, response:IResponse = null):IResponse
		{
			if (response == null) {
				response = new Response(null);
			}
			
			this.response = response;
			
			if (hasEventListener(type)) {
				dispatchEvent( new ControllerEvent(type, response) );
			}
			return response;
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
		
	}
}


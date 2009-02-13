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
	import flight.events.CommandEvent;
	import flight.utils.Registry;
	import flight.utils.Type;
	import flight.utils.getClassName;
	import flight.utils.getType;
	
	/**
	 * Domain acts as an interface to a CommandHistory.
	 * It exposes methods such as undo/redo and routes IUndoableCommands to the current history.  
	 */
	public class DomainController implements IEventDispatcher, ICommandInvoker, ICommandFactory
	{
		private var d:Data = Registry.getInstance(Data, type) as Data;
		
		public function DomainController()
		{
			if(!d.initialized) {
				d.initialized = true;
				init();
			}
		}
		
		public function get type():Class
		{
			return getType(this);
		}
		
		protected function get invoker():ICommandInvoker
		{
			return d.invoker;
		}
		protected function set invoker(value:ICommandInvoker):void
		{
			d.invoker = value;
		}
		
		protected function init():void
		{
		}
		
		/**
		 * Registers a command class with a unique id for later access.
		 */
		public function addCommand(type:String, commandClass:Class):void
		{
			delete d.typesByCommand[ d.commandClasses[type] ];
			d.commandClasses[type] = commandClass;
			d.typesByCommand[commandClass] = type;
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
			return d.commandClasses[type];
		}
		
		public function getCommandType(command:Object):String
		{
			if( !(command is Class) ) {
				command = getType(command);
			}
			return d.typesByCommand[command];
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
				command["client"] = this;
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
		
		/**
		 * Primary method for invoking commands in the Domain class.
		 */
		public function execute(type:String, properties:Object = null):Boolean
		{
			if(!d.executing[type]) {
				d.executing[type] = true;
				
				var command:ICommand = createCommand(type, properties);
				var success:Boolean = (command != null) ? executeCommand(command) :
														  executeScript(type, properties);
				
				d.executing[type] = false;
				return success;
			}
			return false;
		}
		
		/**
		 * Receives an ICommand instance ready for execution and returns its success or failure.
		 */
		public function executeCommand(command:ICommand):Boolean
		{
			if(command == null) {
				return false;
			}
			
			if(command is IAsyncCommand) {
				catchAsyncCommand(command as IAsyncCommand);
			}
			
			var success:Boolean = (d.invoker != null) ? d.invoker.executeCommand(command) :
														command.execute();
			
			if( !(command is IAsyncCommand) ) {
				dispatchCommand(getCommandType(command), command, success);
			} else if(!success) {
				releaseAsyncCommand(command as IAsyncCommand);
			}
			
			return success;
		}
		
		protected function executeScript(type:String, properties:Object = null):Boolean
		{
			if( !(type in this && this[type] is Function) ) {
				return false;
			}
			
			var script:Function = this[type];
			
			var success:Boolean = (properties != null) ? script.apply(null, [].concat(properties)) :
														 script();
			
			dispatchCommand(type, null, success);
			return success;
		}
		
		protected function catchAsyncCommand(command:IAsyncCommand):void
		{
			d.asyncExecutions[command] = true;
			command.addEventListener(Event.COMPLETE, onAsyncEvent);
			command.addEventListener(Event.CANCEL, onAsyncEvent);
		}
		
		protected function releaseAsyncCommand(command:IAsyncCommand):void
		{
			command.removeEventListener(Event.COMPLETE, onAsyncEvent);
			command.removeEventListener(Event.CANCEL, onAsyncEvent);
			delete d.asyncExecutions[command];
		}
		
		protected function dispatchCommand(type:String, command:ICommand = null, success:Boolean = true):void
		{
			if(willTrigger(type)) {
				dispatchEvent( new CommandEvent(type, command, success) );
			}
		}
		
		/**
		 * Catches asynchronous commands upon completion and dispatches an event.
		 */
		private function onAsyncEvent(event:Event):void
		{
			var command:IAsyncCommand = event.target as IAsyncCommand;
			releaseAsyncCommand(command);
			
			dispatchCommand(getCommandType(command), command, Boolean(event.type == Event.COMPLETE));
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
			if(d.eventDispatcher == null) {
				d.eventDispatcher = new EventDispatcher(this);
			}
			
			d.eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if(d.eventDispatcher != null) {
				d.eventDispatcher.removeEventListener(type, listener, useCapture);
			}
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			if(d.eventDispatcher != null && d.eventDispatcher.hasEventListener(event.type)) {
				return d.eventDispatcher.dispatchEvent(event);
			}
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			if(d.eventDispatcher != null) {
				return d.eventDispatcher.hasEventListener(type);
			}
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			if(d.eventDispatcher != null) {
				return d.eventDispatcher.willTrigger(type);
			}
			return false;
		}
		
	}
}

import flight.commands.ICommandInvoker;
import flash.utils.Dictionary;
import flash.events.EventDispatcher;	

class Data
{
	public var initialized:Boolean = false;
	
	public var invoker:ICommandInvoker;
	
	/**
	 * Associative array of command classes organized by their designated type.
	 */
	public var commandClasses:Array = [];
	
	/**
	 * Stores each command's type for dispatching.
	 */
	public var typesByCommand:Dictionary = new Dictionary(true);
	
	public var eventDispatcher:EventDispatcher;
	
	public var asyncExecutions:Dictionary = new Dictionary();		// keeps a strong reference to each IAsyncCommand until completed or canceled
	public var executing:Dictionary = new Dictionary();				// the type of the currently executing script, used to avoid unwanted recursion
	
}


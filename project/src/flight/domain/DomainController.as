package flight.domain
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import flight.commands.CommandItem;
	import flight.commands.IAsyncCommand;
	import flight.commands.ICommand;
	import flight.commands.ICommandFactory;
	import flight.commands.ICommandInvoker;
	import flight.events.CommandEvent;
	import flight.utils.Registry;
	import flight.utils.Type;
	import flight.utils.getType;
	
	/**
	 * Domain acts as an interface to a CommandHistory.
	 * It exposes methods such as undo/redo and routes IUndoableCommands to the current history.  
	 */
	public class DomainController implements IEventDispatcher, ICommandInvoker, ICommandFactory
	{
		protected var d:DomainControllerData;
		
		public function DomainController()
		{
			d = Registry.getInstance(DomainControllerData, type) as DomainControllerData;
			if(!d.initialized)
			{
				d.initialized = true;
				preInit();
				init();
			}
		}
		
		internal function preInit():void
		{
			d.commandClasses = [];
			d.typesByCommand = new Dictionary(true);
			d.asyncExecutions = new Dictionary();
			d.executing = new Dictionary();
		}
		
		protected function init():void
		{
		}
		
		protected function get type():Object
		{
			return getType(this);
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
		public function addCommands(commandItems:Array):void
		{
			for each(var item:CommandItem in commandItems)
			{
				addCommand(item.type, item.commandClass);
			}
		}
		
		/**
		 * Retrieves the command class registered with this type.
		 */
		public function getCommandClass(type:String):Class
		{
			return d.commandClasses[type];
		}
		
		public function getCommandType(command:ICommand):String
		{
			return d.typesByCommand[ command["constructor"] ];
		}
		
		/**
		 * Primary method responsible for command class instantiation, hiding the details
		 * of class inheritance, implementation, origin, etc.
		 */
		public function getCommand(type:String, properties:Object = null):ICommand
		{
			var commandClass:Class = getCommandClass(type);
			if(commandClass == null)
				return null;
			
			var command:ICommand = new commandClass() as ICommand;
			if("client" in command)
				command["client"] = this;
			
			
			for(var i:String in properties)
			{
				if(i in command)
					command[i] = properties[i];
			}
			
			if(properties is Array)
			{
				var list:Array = getArgumentList(command);
				for(i in list)
				{
					if(i in properties)
						command[ list[i] ] = properties[i];
				}
			}
			
			return command;
		}
		
		/**
		 * Primary method for invoking commands in the Domain class.
		 */
		public function execute(type:String, properties:Object = null):Boolean
		{
			if(d.executing[type])
				return false;
			
			d.executing[type] = true;
			var command:ICommand = getCommand(type, properties);
			var success:Boolean = (command != null) ? executeCommand(command) : executeScript(type, properties);
			d.executing[type] = false;
			
			return success;
		}
		
		/**
		 * Receives an ICommand instance ready for execution and returns its success or failure.
		 */
		public function executeCommand(command:ICommand):Boolean
		{
			if(command == null)
				return false;
			
			if(command is IAsyncCommand)
				catchAsyncCommand(command as IAsyncCommand);
			
			var success:Boolean = (d.invoker != null)
								 ? d.invoker.executeCommand(command)
								 : command.execute();
			
			if( !(command is IAsyncCommand) )
				dispatchEvent(new CommandEvent(getCommandType(command), command, success));
			else if(!success)
				releaseAsyncCommand(command as IAsyncCommand);
			
			return success;
		}
		
		protected function executeScript(type:String, properties:Object = null):Boolean
		{
			if( !(type in this && this[type] is Function) )
				return false;
			
			var script:Function = this[type];
			return (properties != null) ? script.apply(null, [].concat(properties)) : script();
		}
		
		protected function catchAsyncCommand(command:IAsyncCommand):void
		{
			d.asyncExecutions[command] = true;
			command.addEventListener(Event.COMPLETE, asyncHandler);
			command.addEventListener(Event.CANCEL, asyncHandler);
		}
		
		protected function releaseAsyncCommand(command:IAsyncCommand):void
		{
			command.removeEventListener(Event.COMPLETE, asyncHandler);
			command.removeEventListener(Event.CANCEL, asyncHandler);
			delete d.asyncExecutions[command];
		}
		
		/**
		 * Catches asynchronous commands upon completion and dispatches an event.
		 */
		protected function asyncHandler(event:Event):void
		{
			var command:IAsyncCommand = event.target as IAsyncCommand;
			releaseAsyncCommand(command);
			
			dispatchEvent(new CommandEvent(getCommandType(command), command, Boolean(event.type == Event.COMPLETE) ));
		}
		
		private static function getArgumentList(command:ICommand):Array
		{
			var list:Array = [];
			
			var argumentList:XMLList = Type.describeProperties(command, "Argument");
			for each(var argument:XML in argumentList)
			{
				if(argument.metadata.(@name == "Argument").arg.@value.length() > 0)
					list[argument.metadata.(@name == "Argument").arg.@value] = argument.@name;
			}
			return list;
		}
		
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if(d.eventDispatcher == null)
				d.eventDispatcher = new EventDispatcher(this);
			
			d.eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if(d.eventDispatcher != null)
				d.eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			if(d.eventDispatcher != null)
				return d.eventDispatcher.dispatchEvent(event);
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			if(d.eventDispatcher != null)
				return d.eventDispatcher.hasEventListener(type);
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			if(d.eventDispatcher != null)
				return d.eventDispatcher.willTrigger(type);
			return false;
		}
		
	}
}

import flight.commands.ICommandInvoker;
import flash.utils.Dictionary;
import flash.events.EventDispatcher;	

class DomainControllerData
{
	public var initialized:Boolean;
	
	public var invoker:ICommandInvoker;
	
	/**
	 * Associative array of command classes organized by their designated type.
	 */
	public var commandClasses:Array;
	
	/**
	 * Stores each command's type for dispatching.
	 */
	public var typesByCommand:Dictionary;
	
	public var eventDispatcher:EventDispatcher;
	
	public var asyncExecutions:Dictionary;			// keeps a strong reference to each IAsyncCommand until completed or canceled
	public var executing:Dictionary;				// the type of the currently executing script, used to avoid unwanted recursion

}


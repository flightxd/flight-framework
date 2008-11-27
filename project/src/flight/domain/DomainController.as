package flight.domain
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import flight.commands.AsyncCommand;
	import flight.commands.CommandItem;
	import flight.commands.ICommand;
	import flight.commands.ICommandFactory;
	import flight.commands.ICommandInvoker;
	import flight.controller.Controller;
	import flight.events.AsyncEvent;
	import flight.events.CommandEvent;
	import flight.utils.Registry;
	import flight.utils.getType;
	
	/**
	 * Domain acts as an interface to a CommandHistory.
	 * It exposes methods such as undo/redo and routes IUndoableCommands to the current history.  
	 */
	public class DomainController extends Controller implements ICommandInvoker, ICommandFactory
	{
		protected var invoker:ICommandInvoker;
		
		/**
		 * Associative array of command classes organized by their designated type.
		 */
		protected var commandClasses:Array;
		
		/**
		 * Stores each command's type for dispatching.
		 */
		protected var typesByCommand:Dictionary;
		
		private var asyncExecutions:Dictionary;			// keeps a strong reference to each AsyncCommand until completed or canceled
		private var executing:Dictionary;				// the type of the currently executing script, used to avoid unwanted recursion
		
		
		public function DomainController()
		{
			commandClasses = [];
			typesByCommand = new Dictionary(true);
			asyncExecutions = new Dictionary();
			executing = new Dictionary();
			
			Registry.register(index, this, view);
			initAdapters();
		}
		
		[Bindable(event="propertyChange")]
		override public function set view(value:IEventDispatcher):void
		{
			if(view == value)
				return;
			
			Registry.unregister(index, view);
			super.view = value;
			Registry.register(index, this, view);
		}
		
		protected function get index():Object
		{
			return getType(this);
		}
		
		override public function initialized(document:Object, id:String):void
		{
			// do NOT set view automatically as does Controller
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
			return commandClasses[type];
		}
		
		public function getCommandType(command:ICommand):String
		{
			return typesByCommand[ command["constructor"] ];
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
			
			var command:ICommand;
			var params:Array = properties as Array;
			switch( (params != null) ? params.length : 0 )
			{
				case 0 : command = new commandClass() as ICommand; break;
				case 1 : command = new commandClass(params[0]) as ICommand; break;
				case 2 : command = new commandClass(params[0], params[1]) as ICommand; break;
				case 3 : command = new commandClass(params[0], params[1], params[2]) as ICommand; break;
				case 4 : command = new commandClass(params[0], params[1], params[2], params[3]) as ICommand; break;
				case 5 : command = new commandClass(params[0], params[1], params[2], params[3], params[4]) as ICommand; break;
				default : command = new commandClass(params[0], params[1], params[2], params[3], params[4], params[5]) as ICommand; break;
			}
			
			if("client" in command)
				command["client"] = this;
			for(var i:String in properties)
			{
				if(i in command)
					command[i] = properties[i];
			}
			
			return command;
		}
		
		/**
		 * Primary method for invoking commands in the Domain class.
		 */
		public function execute(type:String, properties:Object = null):Boolean
		{
			if(executing[type])
				return false;
			
			executing[type] = true;
			var command:ICommand = getCommand(type, properties);
			var success:Boolean = (command != null) ? executeCommand(command) : executeScript(type, properties);
			executing[type] = false;
			
			return success;
		}
		
		/**
		 * Receives an ICommand instance ready for execution and returns its success or failure.
		 */
		public function executeCommand(command:ICommand):Boolean
		{
			if(command == null)
				return false;
			
			if(command is AsyncCommand)
				catchAsyncCommand(command as AsyncCommand);
			
			var success:Boolean = (invoker != null)
						? invoker.executeCommand(command)
						: command.execute();
			
			if( !(command is AsyncCommand) )
				dispatchEvent(new CommandEvent(getCommandType(command), command, success));
			else if(!success)
				releaseAsyncCommand(command as AsyncCommand);
			
			return success;
		}
		
		protected function executeScript(type:String, properties:Object = null):Boolean
		{
			if( !(type in this && this[type] is Function) )
				return false;
			
			var script:Function = this[type];
			return (properties != null) ? script.apply(null, [].concat(properties)) : script();
		}
		
		protected function initAdapters():void
		{
		}
		
		protected function catchAsyncCommand(command:AsyncCommand):void
		{
			asyncExecutions[command] = true;
			command.addEventListener(AsyncEvent.COMPLETE, asyncHandler);
			command.addEventListener(AsyncEvent.CANCEL, asyncHandler);
		}
		
		protected function releaseAsyncCommand(command:AsyncCommand):void
		{
			command.removeEventListener(AsyncEvent.COMPLETE, asyncHandler);
			command.removeEventListener(AsyncEvent.CANCEL, asyncHandler);
			delete asyncExecutions[command];
		}
		
		/**
		 * Catches asynchronous commands upon completion and dispatches an event.
		 */
		protected function asyncHandler(event:AsyncEvent):void
		{
			var command:AsyncCommand = event.target as AsyncCommand;
			releaseAsyncCommand(command);
			
			dispatchEvent(new CommandEvent(getCommandType(command), command, Boolean(event.type == AsyncEvent.COMPLETE) ));
		}
		
	}
}
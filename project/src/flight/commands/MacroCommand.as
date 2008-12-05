package flight.commands
{
	import flash.events.Event;
	
	import flight.domain.AsyncCommand;
	
	[DefaultProperty("commands")]
	/**
	 * The MacroCommand class is a single command that executes
	 * a list of many commands.
	 */
	public class MacroCommand extends AsyncCommand implements ICombinableCommand
	{
		/**
		 * The list of commands to be executed.
		 */
		public var commands:Array;
		
		public var queue:Boolean = true;
		
		private var lastCommand:ICommand;
		
		public function MacroCommand(commands:Array = null)
		{
			this.commands = commands != null ? commands : [];
		}
		
		public function get combining():Boolean
		{
			return false;
		}
		
		/**
		 * Runs through the command list in order, executing each.
		 */
		override public function execute():Boolean
		{
			lastCommand = null;
			return executeNext();
		}
		
		/**
		 * Runs through the list of commands in reverse order, verifying that
		 * each is undable before calling undo on the individual command.
		 */
		public function undo():void
		{
			var i:int = (lastCommand != null) ? commands.indexOf(lastCommand) : commands.length-1;
			for(i; i >= 0; i--)
			{
				var command:ICommand = commands[i];
				if(command is IUndoableCommand)
					IUndoableCommand(command).undo();
			}
		}
		
		public function redo():void
		{
			lastCommand = null;
			executeNext();
		}
		
		public function combine(command:ICombinableCommand):Boolean
		{
			commands.push(command);
			return true;
		}
		
		protected function executeNext(event:Event = null):Boolean
		{
			var i:int = (lastCommand != null) ? commands.indexOf(lastCommand) + 1 : 0;
			if(i >= commands.length)
			{
				dispatchComplete();
				return true;
			}
			
			lastCommand = commands[i];
			if(lastCommand is AsyncCommand && queue)
			{
				var asyncCommand:AsyncCommand = lastCommand as AsyncCommand;
				if(!asyncCommand.hasEventListener(Event.COMPLETE))
				{
					asyncCommand.addEventListener(Event.COMPLETE, executeNext);
					asyncCommand.addEventListener(Event.CANCEL, dispatchCancel);
				}
				return asyncCommand.execute();
			}
			
			if(lastCommand.execute())
				return executeNext();
			else
				return false;
		}
		
	}
}
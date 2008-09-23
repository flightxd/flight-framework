package flight.events
{
	import flash.events.Event;
	
	import flight.commands.ICommand;
	
	public class CommandEvent extends Event
	{
		private var _command:ICommand;
		private var _success:Boolean;
		
		public function CommandEvent(type:String, command:ICommand, success:Boolean = true)
		{
			super(type);
			_command = command;
			_success = success;
		}
		
		/**
		 * The ICommand class associated with the ControllerEvent as a read-only.
		 */
		public function get command():ICommand
		{
			return _command;
		}
		
		public function get success():Boolean
		{
			return _success;
		}
		
	}
}

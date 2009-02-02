package com.flightxd.flightcontacts.domains.user.commands
{
	import flight.commands.AsyncCommand;

	public class Save extends AsyncCommand
	{
		public function Save(editedUser:String)
		{
		}
		
		public function execute():Boolean
		{
			
			dispatchComplete();
			return true;
		}
		
	}
}
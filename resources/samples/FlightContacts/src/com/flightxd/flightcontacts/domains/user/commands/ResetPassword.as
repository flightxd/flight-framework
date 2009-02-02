package com.flightxd.flightcontacts.domains.user.commands
{
	import flight.commands.AsyncCommand;

	public class ResetPassword extends AsyncCommand
	{
		public function ResetPassword(email:String)
		{
		}
		
		public function execute():Boolean
		{
			
			dispatchComplete();
			return true;
		}
		
	}
}
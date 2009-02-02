package com.flightxd.flightcontacts.domains.user.commands
{
	import flight.commands.AsyncCommand;

	public class Register extends AsyncCommand
	{
		public function Register(user:String)
		{
		}
		
		public function execute():Boolean
		{
			
			dispatchComplete();
			return true;
		}
		
	}
}
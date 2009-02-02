package com.flightxd.flightcontacts.domains.user.commands
{
	import flight.commands.AsyncCommand;

	public class Login extends AsyncCommand
	{
		public function Login(email:String, password:String)
		{
		}
		
		public function execute():Boolean
		{
			
			dispatchComplete();
			return true;
		}
		
	}
}
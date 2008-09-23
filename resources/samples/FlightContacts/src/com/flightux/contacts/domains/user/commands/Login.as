package com.flightux.contacts.domains.user.commands
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
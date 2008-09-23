package com.flightux.contacts.domains.contact
{
	import com.flightux.contacts.domains.user.commands.*;
	
	import flight.domain.DomainController;

	public class UserController extends DomainController
	{
		public const LOGIN:String = "login";
		public const LOGOUT:String = "logout";
		public const REGISTER:String = "register";
		public const RESET_PASSWORD:String = "resetPassword";
		public const SAVE:String = "save";
		
		public function UserController()
		{
			addCommand(LOGIN, Login);
			addCommand(LOGOUT, Logout);
			addCommand(REGISTER, Register);
			addCommand(RESET_PASSWORD, ResetPassword);
			addCommand(SAVE, Save);
		}
		
		public function login(email:String, password:String):Boolean
		{
			return execute(LOGIN);
		}
		
		public function register():Boolean
		{
			return execute(LOGOUT);
		}
		
		public function register(user:String):Boolean
		{
			return execute(REGISTER);
		}
		
		public function resetPassword(email:String):Boolean
		{
			return execute(RESET_PASSWORD);
		}
		
		public function save(editedUser:String):Boolean
		{
			return execute(SAVE);
		}
		
	}
}
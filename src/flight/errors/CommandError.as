/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.errors
{
	import flight.commands.ICommand;
	
	public class CommandError extends Error
	{
		private var _command:ICommand;
		
		public function CommandError(command:ICommand, message:String="", id:int = 0)
		{
			_command = command;
			super(message, id);
		}
		
		public function get command():ICommand
		{
			return _command;
		}
	}
}
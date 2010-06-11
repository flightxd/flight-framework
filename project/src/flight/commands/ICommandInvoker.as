/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.commands
{
	/**
	 * A ICommandInvoker is any object that receives and executes commands. These are often classes
	 * that manage histories (undo/redo), transactions, logging, etc.
	 */
	public interface ICommandInvoker
	{
		/**
		 * Receives an ICommand instance ready for execution and returns its success or failure.
		 */
		function executeCommand(command:ICommand):void;
	}
}
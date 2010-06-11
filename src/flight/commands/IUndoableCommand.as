/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.commands
{
	/**
	 * The base interface for commands that support undo and redo.
	 */
	public interface IUndoableCommand extends ICommand
	{
		/**
		 * Reverses the action performed by execute.
		 */
		function undo():void;
		
		/**
		 * Restores a reversed action following an undo.
		 */
		function redo():void;
	}
}
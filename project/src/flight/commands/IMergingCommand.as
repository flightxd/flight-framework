/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.commands
{
	import flight.utils.IMerging;
	
	/**
	 * An interface for commands that support undo and redo and can be merged into
	 * one undoable action.
	 */
	public interface IMergingCommand extends IUndoableCommand, IMerging
	{
		/**
		 * Flags the CommandHistory to treat this as a merging command.
		 */
		function get merging():Boolean;
	}
}

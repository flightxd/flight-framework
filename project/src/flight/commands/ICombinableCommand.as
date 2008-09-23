package flight.commands
{
	/**
	 * An interface for commands that support undo and redo and can be combined into
	 * one undoable action.
	 */
	public interface ICombinableCommand extends IUndoableCommand
	{
		/**
		 * Flags the CommandHistory to treat this as a combining command.
		 */
		function get combining():Boolean;
		
		/**
		 * Gives the first executed command the opportunity to combine itself with
		 * another combinable command which was called later and return the success
		 * of the combination
		 */
		 function combine(command:ICombinableCommand):Boolean;
	}
}
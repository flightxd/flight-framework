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
		function executeCommand(command:ICommand):Boolean;
	}
}
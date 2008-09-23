package flight.commands
{
	/**
	 * The ICommandHistory is the basic interface for all histories that execute and store
	 * undoable commands, allowing undo and redo, limiting the level of undo's, etc.
	 */
	public interface ICommandHistory extends ICommandInvoker
	{
		/**
		 * Shows that undo can be called successfully.
		 */
		function get canUndo():Boolean;
		
		/**
		 * Shows that redo can be called successfully.
		 */
		function get canRedo():Boolean;
		
		/**
		 * The limit to the length of the history; the number of commands that are stored.
		 */
		function get undoLevel():uint;
		function set undoLevel(value:uint):void;
		
		/**
		 * The history undo, restoring state to a certain point in time.
		 */
		function undo():Boolean;
		
		/**
		 * The history redo, updating state following an undo.
		 */
		function redo():Boolean;
		
		/**
		 * Resets the combining command behavior.
		 */
		function resetCombining():Boolean;
		
		/**
		 * Releases all commands from the history.
		 */
		function clearHistory():Boolean;
	}
}
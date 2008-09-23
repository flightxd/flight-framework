package flight.domain
{
	import flight.commands.CommandHistory;
	import flight.commands.ICommand;
	import flight.commands.ICommandHistory;
	import flight.events.CommandEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.PropertyChangeEvent;
	
	/**
	 * HistoryDomain acts as an interface to a CommandHistory.
	 * It exposes methods such as undo/redo and routes IUndoableCommands to the current history.  
	 */
	public class HistoryController extends DomainController implements ICommandHistory
	{
		private var _commandHistory:CommandHistory;
		private var _canUndo:Boolean = false;
		private var _canRedo:Boolean = false;
		
		public function HistoryController()
		{
			commandHistory = new CommandHistory();
			
			BindingUtils.bindProperty(this, "canUndo", this, ["commandHistory", "canUndo"]);
			BindingUtils.bindProperty(this, "canRedo", this, ["commandHistory", "canRedo"]);
		}
		
		/**
		 * A reference to the current commandHistory.
		 */
		[Bindable(event="propertyChange")]
		public function get commandHistory():CommandHistory
		{
			return _commandHistory;
		}
		public function set commandHistory(value:CommandHistory):void
		{
			if(_commandHistory == value)
				return;
			
			var oldValue:CommandHistory = _commandHistory;
			_commandHistory = value;
			invoker = _commandHistory;
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "commandHistory", oldValue, value));
		}
		
		/**
		 * Shows that undo can be called successfully.
		 */
		[Bindable(event="propertyChange")]
		public function get canUndo():Boolean
		{
			return _canUndo;
		}
		/**
		 * @private 
		 */		
		public function set canUndo(value:Boolean):void
		{
			if(_canUndo == value)
				return;
			
			var oldValue:Boolean = _canUndo;
			_canUndo = value;
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "canUndo", oldValue, value));
		}
		
		/**
		 * Shows that redo can be called successfully.
		 */
		[Bindable(event="propertyChange")]
		public function get canRedo():Boolean
		{
			return _canRedo;
		}
		/**
		 * @private 
		 */
		public function set canRedo(value:Boolean):void
		{
			if(_canRedo == value)
				return;
			
			var oldValue:Boolean = _canRedo;
			_canRedo = value;
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "canRedo", oldValue, value));
		}
		
		/**
		 * The limit to the length of the commandHistory; the number of commands that are stored.
		 */
		public function get undoLevel():uint
		{
			return commandHistory.undoLevel;
		}
		/**
		 * @private 
		 */
		public function set undoLevel(value:uint):void
		{
			commandHistory.undoLevel = value;
		}
		
		/**
		 * The commandHistory undo, restoring state to a certain point in time.
		 */
		public function undo():Boolean
		{
			var command:ICommand = commandHistory.currentCommand;
			var success:Boolean = commandHistory.undo();
			if(success)
				dispatchEvent(new CommandEvent(getCommandType(command), command, true));
			return success;
		}
		
		/**
		 * The commandHistory redo, updating state following an undo.
		 */
		public function redo():Boolean
		{
			var success:Boolean = commandHistory.redo();
			var command:ICommand = commandHistory.currentCommand;
			if(success)
				dispatchEvent(new CommandEvent(getCommandType(command), command, false));
			return success;
		}
		
		/**
		 * Resets the combining command behavior.
		 */
		public function resetCombining():Boolean
		{
			return commandHistory.resetCombining();
		}
		
		/**
		 * Releases all commands from the commandHistory.
		 */
		public function clearHistory():Boolean
		{
			return commandHistory.clearHistory();
		}
		
	}
}
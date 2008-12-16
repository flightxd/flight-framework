package flight.domain
{
	import flight.commands.CommandHistory;
	import flight.commands.ICommand;
	import flight.commands.ICommandHistory;
	import flight.events.CommandEvent;
	import flight.events.PropertyChangeEvent;
	import flight.utils.Registry;
	
	import mx.binding.utils.BindingUtils;
	
	/**
	 * HistoryDomain acts as an interface to a CommandHistory.
	 * It exposes methods such as undo/redo and routes IUndoableCommands to the current history.  
	 */
	public class HistoryController extends DomainController implements ICommandHistory
	{
		private var h:HistoryControllerData;
		
		public function HistoryController()
		{
			h = Registry.getInstance(HistoryControllerData, type) as HistoryControllerData;
			super();		// TODO: review a way to avoid calling super...
		}
		
		override internal function preInit():void
		{
			super.preInit();
			
			commandHistory = new CommandHistory();
			
			// TODO: remove binding and _canUndo/_canRedo - reflect commandHistory
			BindingUtils.bindProperty(this, "canUndo", this, ["commandHistory", "canUndo"]);
			BindingUtils.bindProperty(this, "canRedo", this, ["commandHistory", "canRedo"]);
		}
		
		/**
		 * A reference to the current commandHistory.
		 */
		[Bindable(event="propertyChange")]
		public function get commandHistory():CommandHistory
		{
			return h._commandHistory;
		}
		public function set commandHistory(value:CommandHistory):void
		{
			if(h._commandHistory == value)
				return;
			
			d.invoker = value;
			PropertyChangeEvent.dispatchPropertyChange(this, "commandHistory", h._commandHistory, h._commandHistory = value);
		}
		
		/**
		 * Shows that undo can be called successfully.
		 */
		[Bindable(event="propertyChange")]
		public function get canUndo():Boolean
		{
			return h._canUndo;
		}
		/**
		 * @private 
		 */		
		public function set canUndo(value:Boolean):void
		{
			if(h._canUndo == value)
				return;
			
			PropertyChangeEvent.dispatchPropertyChange(this, "canUndo", h._canUndo, h._canUndo = value);
		}
		
		/**
		 * Shows that redo can be called successfully.
		 */
		[Bindable(event="propertyChange")]
		public function get canRedo():Boolean
		{
			return h._canRedo;
		}
		/**
		 * @private 
		 */
		public function set canRedo(value:Boolean):void
		{
			if(h._canRedo == value)
				return;
			
			var oldValue:Boolean = h._canRedo;
			h._canRedo = value;
			PropertyChangeEvent.dispatchPropertyChange(this, "canRedo", oldValue, value);
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

import flight.commands.CommandHistory;

class HistoryControllerData
{
	public var _commandHistory:CommandHistory;
	public var _canUndo:Boolean = false;
	public var _canRedo:Boolean = false;
}


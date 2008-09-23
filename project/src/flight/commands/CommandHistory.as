package flight.commands
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import flight.utils.Type;
	
	import mx.events.PropertyChangeEvent;
	
	/**
	 * The CommandHistory executes and stores undoable commands as a history,
	 * allowing undo and redo, limiting the level of undo's, etc.
	 */
	public class CommandHistory extends EventDispatcher implements ICommandHistory
	{
		private var combiningCommand:ICombinableCommand;
		private var _history:Array;
		private var _currentCommand:IUndoableCommand;
		private var _canUndo:Boolean = false;
		private var _canRedo:Boolean = false;
		private var _currentPosition:int = 0;			// the internal position of the _history at the present time.
		private var _undoLevel:uint = 100;				// the internal level of undo's allowed.
		
		public function CommandHistory()
		{
			_history = [];
			currentPosition = 0;
		}
		
		/**
		 * The actual list of commands, in order of occurance. This list should
		 * not be manipultated directly and should be treated as read only.
		 */
		[Bindable(event="propertyChange")]
		public function get history():Array
		{
			return _history;
		}
		
		/**
		 * The current command in the _history, often the last command executed.
		 */
		[Bindable(event="propertyChange")]
		public function get currentCommand():IUndoableCommand
		{
			return _currentCommand;
		}
		public function set currentCommand(value:IUndoableCommand):void
		{
			if(_currentCommand == value)
				return;
			
			var oldValue:IUndoableCommand = _currentCommand;
			_currentCommand = value;
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "currentCommand", oldValue, value));
		}
		
		/**
		 * Indicates whether there are commands availble to undo
		 */
		[Bindable(event="propertyChange")]
		public function get canUndo():Boolean
		{
			return _canUndo;
		}
		
		/**
		 * Indicates whether there are commands availble to redo
		 */
		[Bindable(event="propertyChange")]
		public function get canRedo():Boolean
		{
			return _canRedo;
		}
		
		/**
		 * The internal position of the _history at the present time.
		 */
		[Bindable(event="propertyChange")]
		public function get currentPosition():int
		{
			return _currentPosition;
		}
		public function set currentPosition(value:int):void
		{
			if(_currentPosition == value)
				return;
			
			var oldValue:int = _currentPosition;
			_currentPosition = value;
			
			if(_currentPosition > undoLevel)
			{
				_history.splice(0, _currentPosition - undoLevel);
				_currentPosition = value = undoLevel;
				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "history", oldValue, value));
			}
			
			currentCommand = _history[_currentPosition-1] as IUndoableCommand;
			
			// update canUndo and canRedo
			if(_canUndo != Boolean(_currentPosition > 0))
			{
				_canUndo = !_canUndo;
				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "canUndo", !_canUndo, _canUndo));
			}
			if(_canRedo != Boolean(_currentPosition < _history.length))
			{
				_canRedo = !_canRedo;
				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "canRedo", !_canRedo, _canRedo));
			}
			
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "currentPosition", oldValue, value));
		}
		
		/**
		 * The undo level of commands that will be stored in _history. Older commands
		 * will be removed from _history, freeing up memory as this limit is exceeded.
		 */
		public function get undoLevel():uint
		{
			return _undoLevel;
		}
		public function set undoLevel(value:uint):void
		{
			if(_undoLevel == value)
				return;
			
			_undoLevel = value;
			if(currentPosition > undoLevel)
			{
				_history.splice(0, currentPosition - undoLevel);
				currentPosition = undoLevel;
				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "history", _history, _history));
			}
		}
		
		/**
		 * Adds a command to the _history before executing it. This is how all commands should
		 * be introduced to the CommandHistory, to ensure undo can rely on an initial execution.
		 */
		public function executeCommand(command:ICommand):Boolean
		{
			if( !(command is IUndoableCommand) )
				return command.execute();
			
			if(command is AsyncCommand)
				AsyncCommand(command).addEventListener(Event.CANCEL, asyncErrorHandler, false, 0, true);
			
			if(command is ICombinableCommand && ICombinableCommand(command).combining)
			{
				if(combiningCommand == null || Type.getType(combiningCommand) != Type.getType(command))
					combiningCommand = command as ICombinableCommand;
				else
					return combiningCommand.combine(command as ICombinableCommand);
			}
			else
				combiningCommand = null;
			
			var success:Boolean = command.execute();
			if(success && _history.indexOf(command) == -1)
			{
				// ensure that if the command is an AsyncCommand that it hasn't dispatched the CANCEL before adding it to the history
				if( !(command is AsyncCommand) || AsyncCommand(command).hasEventListener(Event.CANCEL))
				{
					_history.splice(currentPosition, _history.length, command);
					currentPosition++;
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "history", _history, _history));
				}
			}
			return success;
		}
		
		/**
		 * Reverses the action of the last command executed.
		 */
		public function undo():Boolean
		{
			if(!canUndo)
				return false;
			
			var command:IUndoableCommand = _history[currentPosition-1] as IUndoableCommand;
			command.undo();
			currentPosition--;
			return true;
		}
		
		/**
		 * Re-executes the next command in the _history through its redo method.
		 */
		public function redo():Boolean
		{
			if(!canRedo)
				return false;
			
			var command:IUndoableCommand = _history[currentPosition] as IUndoableCommand;
			command.redo();
			currentPosition++;
			return true;
		}
		
		/**
		 * Resets the combining command behavior.
		 */
		public function resetCombining():Boolean
		{
			if(combiningCommand == null)
				return false;
			
			combiningCommand = null;
			return true;
		}
		
		/**
		 * Clears all commands from the history and resets the present position to zero.
		 */
		public function clearHistory():Boolean
		{
			if(_history == null || _history.length == 0)
				return false;
			
			_history = [];
			currentPosition = 0;
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "history", _history, _history));
			return true;
		}
		
		/**
		 * Catches asynchronous commands upon cancelation to remove from the history.
		 */
		protected function asyncErrorHandler(event:Event):void
		{
			var command:AsyncCommand = event.target as AsyncCommand;
			command.removeEventListener(Event.CANCEL, asyncErrorHandler);
			if(_history.indexOf(command) != -1)
			{
				_history.splice(_history.indexOf(command), 1);
				currentPosition--;
				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "history", _history, _history));
			}
		}
		
	}
}
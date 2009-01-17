////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2009 Tyler Wright, Robert Taylor, Jacob Wright
//	
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//	
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package flight.commands
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import flight.events.PropertyChangeEvent;
	import flight.utils.getType;
	
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
		[Bindable(event="propertyChange", flight="true")]
		public function get history():Array
		{
			return _history;
		}
		
		/**
		 * The current command in the _history, often the last command executed.
		 */
		[Bindable(event="propertyChange", flight="true")]
		public function get currentCommand():IUndoableCommand
		{
			return _currentCommand;
		}
		public function set currentCommand(value:IUndoableCommand):void
		{
			if(_currentCommand == value) {
				return;
			}
			
			PropertyChangeEvent.dispatchPropertyChange(this, "currentCommand", _currentCommand, _currentCommand = value);
		}
		
		/**
		 * Indicates whether there are commands availble to undo
		 */
		[Bindable(event="propertyChange", flight="true")]
		public function get canUndo():Boolean
		{
			return _canUndo;
		}
		
		/**
		 * Indicates whether there are commands availble to redo
		 */
		[Bindable(event="propertyChange", flight="true")]
		public function get canRedo():Boolean
		{
			return _canRedo;
		}
		
		/**
		 * The internal position of the _history at the present time.
		 */
		[Bindable(event="propertyChange", flight="true")]
		public function get currentPosition():int
		{
			return _currentPosition;
		}
		public function set currentPosition(value:int):void
		{
			var oldValue:int = _currentPosition;
			_currentPosition = value;
			
			if(_currentPosition > undoLevel) {
				_history.splice(0, _currentPosition - undoLevel);
				PropertyChangeEvent.dispatchPropertyChange(this, "history", _history, _history);
				_currentPosition = undoLevel;
			}
			
			currentCommand = _history[_currentPosition-1];
			
			// update canUndo and canRedo
			if(_canUndo != Boolean(_currentPosition > 0)) {
				PropertyChangeEvent.dispatchPropertyChange(this, "canUndo", _canUndo, _canUndo = !_canUndo);
			}
			if(_canRedo != Boolean(_currentPosition < _history.length)) {
				PropertyChangeEvent.dispatchPropertyChange(this, "canRedo", _canRedo, _canRedo = !_canRedo);
			}
			
			PropertyChangeEvent.dispatchPropertyChange(this, "currentPosition", oldValue, _currentPosition);
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
			if(_undoLevel == value) {
				return;
			}
			
			_undoLevel = value;
			if(currentPosition > undoLevel) {
				currentPosition = currentPosition;
			}
		}
		
		/**
		 * Will step throught the undo / redo to a given position executing all commands
		 * within that sequence.
		 */
		public function setCurrentPosition( index:uint ):void
		{
			var count:int;
			
			if(currentPosition > index) {
				count = (currentPosition - 1) - index;
				while(count-- && canUndo) {
					undo();
				}
			} else {
				count = index - (currentPosition - 1);
				while (count-- && canRedo) {
					redo();
				}					
			}
		}
		
		/**
		 * Adds a command to the _history before executing it. This is how all commands should
		 * be introduced to the CommandHistory, to ensure undo can rely on an initial execution.
		 */
		public function executeCommand(command:ICommand):Boolean
		{
			if( !(command is IUndoableCommand) ) {
				return command.execute();
			}
			
			if(command is IAsyncCommand) {
				IAsyncCommand(command).addEventListener(Event.CANCEL, asyncErrorHandler, false, 0, true);
			}
			
			if(command is ICombinableCommand && ICombinableCommand(command).combining) {
				if(combiningCommand == null || getType(combiningCommand) != getType(command)) {
					combiningCommand = command as ICombinableCommand;
				} else {
					return combiningCommand.combine(command as ICombinableCommand);
				}
			}
			else {
				combiningCommand = null;
			}
			
			var success:Boolean = command.execute();
			if(success && _history.indexOf(command) == -1) {
				// ensure that if the command is an IAsyncCommand that it hasn't dispatched the CANCEL before adding it to the history
				if( !(command is IAsyncCommand) || IAsyncCommand(command).hasEventListener(Event.CANCEL)) {
					_history.splice(currentPosition, _history.length, command);
					PropertyChangeEvent.dispatchPropertyChange(this, "history", _history, _history);
					currentPosition++;
				}
			}
			return success;
		}
		
		/**
		 * Reverses the action of the last command executed.
		 */
		public function undo():Boolean
		{
			if(!canUndo) {
				return false;
			}
			
			var command:IUndoableCommand = _history[currentPosition-1];
			command.undo();
			currentPosition--;
			return true;
		}
		
		/**
		 * Re-executes the next command in the _history through its redo method.
		 */
		public function redo():Boolean
		{
			if(!canRedo) {
				return false;
			}
			
			var command:IUndoableCommand = _history[currentPosition];
			command.redo();
			currentPosition++;
			return true;
		}
		
		/**
		 * Resets the combining command behavior.
		 */
		public function resetCombining():Boolean
		{
			if(combiningCommand == null) {
				return false;
			}
			
			combiningCommand = null;
			return true;
		}
		
		/**
		 * Clears all commands from the history and resets the present position to zero.
		 */
		public function clearHistory():Boolean
		{
			if(_history.length == 0) {
				return false;
			}
			
			PropertyChangeEvent.dispatchPropertyChange(this, "history", _history, _history = []);
			currentPosition = 0;
			return true;
		}
		
		/**
		 * Catches asynchronous commands upon cancelation to remove from the history.
		 */
		protected function asyncErrorHandler(event:Event):void
		{
			var command:IAsyncCommand = event.target as IAsyncCommand;
			command.removeEventListener(Event.CANCEL, asyncErrorHandler);
			if(_history.indexOf(command) != -1) {
				_history.splice(_history.indexOf(command), 1);
				PropertyChangeEvent.dispatchPropertyChange(this, "history", _history, _history);
				currentPosition--;
			}
		}
		
	}
}
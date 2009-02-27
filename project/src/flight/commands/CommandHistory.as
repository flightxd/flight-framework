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
	
	import flight.events.PropertyEvent;
	import flight.utils.getType;
	import flight.vo.ValueObject;
	
	/**
	 * The CommandHistory executes and stores undoable commands as a history,
	 * allowing undo and redo, limiting the level of undo's, etc.
	 */
	public class CommandHistory extends ValueObject implements ICommandHistory
	{
		protected var combiningCommand:ICombinableCommand;
		protected var asyncError:Boolean = false;
		
		private var _canUndo:Boolean = false;
		private var _canRedo:Boolean = false;
		private var _historyLength:int = 0;
		private var _historyPosition:int = 0;
		private var _currentPosition:int = 0;			// the internal position of the _history at the present time.
		private var _undoLimit:uint = 10;				// the internal level of undo's allowed.
		private var _commands:Array = [];
		private var _currentCommand:IUndoableCommand;
		
		
		/**
		 * The actual list of commands, in order of occurance. This list should
		 * not be manipultated directly and should be treated as read only.
		 */
		[Bindable(event="propertyChange", flight="true")]
		public function get commands():Array
		{
			return _commands;
		}
		
		/**
		 * The current command in the _history, often the last command executed.
		 */
		[Bindable(event="propertyChange", flight="true")]
		public function get currentCommand():IUndoableCommand
		{
			return _currentCommand;
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
		
		[Bindable(event="propertyChange", flight="true")]
		public function get historyLength():int
		{
			return _historyLength;
		}
		
		[Bindable(event="propertyChange", flight="true")]
		public function get historyPosition():int
		{
			return _historyPosition;
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
			if(value > _commands.length) {
				value = _commands.length;
			} else if(value < 0) {
				value = 0;
			}
			
			if(_currentPosition != value) {
				var oldValues:Array = [_currentCommand, _currentPosition, _historyPosition];
				
				var i:int, command:IUndoableCommand;
				if(_currentPosition > value) {
					
					for(i = _currentPosition; i > value; i--) {
						command = _commands[i-1];
						command.undo();
					}
				} else {
					
					for(i = _currentPosition; i < value; i++) {
						command = _commands[i];
						command.redo();
					}
				}
				
				_currentPosition = value;
				_historyPosition = _historyLength - (_commands.length - _currentPosition);
				_currentCommand = _commands[_currentPosition-1];
				updateProperties();
				
				PropertyEvent.dispatchChangeList(this, ["currentCommand", "currentPosition", "historyPosition"], oldValues);
			}
		}
		
		/**
		 * The undo level of commands that will be stored in _history. Older commands
		 * will be removed from _history, freeing up memory as this limit is exceeded.
		 */
		[Bindable(event="propertyChange", flight="true")]
		public function get undoLimit():int
		{
			return _undoLimit;
		}
		public function set undoLimit(value:int):void
		{
			if(_undoLimit != value) {
				var oldValues:Array = [_commands, _currentPosition, _undoLimit];
				
				_undoLimit = value > 0 ? value : int.MAX_VALUE;
				_commands.splice(_currentPosition, _commands.length - _currentPosition);
				if(_commands.length > _undoLimit) {
					_currentPosition = _undoLimit;
					_commands.splice(0, _commands.length - _undoLimit);
				}
				_commands = [].concat(_commands);
				updateProperties();
				
				PropertyEvent.dispatchChangeList(this, ["commands", "currentPosition", "undoLimit"], oldValues);
			}
		}
		
		/**
		 * Adds a command to the _history before executing it. This is how all commands should
		 * be introduced to the CommandHistory, to ensure undo can rely on an initial execution.
		 */
		public function executeCommand(command:ICommand):void
		{
			if( !(command is IUndoableCommand) || _commands.indexOf(command) != -1) {
				command.execute();
			} else {
				
				if(command is ICombinableCommand && ICombinableCommand(command).combining) {
					
					if(combiningCommand == null || getType(combiningCommand) != getType(command)) {
						combiningCommand = command as ICombinableCommand;
					} else {
						
						var combined:Boolean = combiningCommand.combine(command as ICombinableCommand);
						if(combined) {
							return;
						}
						
						combiningCommand = command as ICombinableCommand;
					}
					
				} else {
					combiningCommand = null;
				}
				
				asyncError = false;
				if(command is IAsyncCommand) {
					IAsyncCommand(command).addEventListener(Event.CANCEL, onAsyncError, false, 0, true);
				}
				
				command.execute();
				
				if(asyncError) {
					return;
				}
				
				var oldValues:Array = [_commands, _currentCommand, _currentPosition, _historyPosition, _historyLength];
				
				_commands.splice(_currentPosition, _commands.length - _currentPosition, command);
				if(_commands.length > _undoLimit) {
					_currentPosition = _undoLimit;
					_commands.splice(0, _commands.length - _undoLimit);
				} else {
					_currentPosition++;
				}
				_currentCommand = _commands[_currentPosition-1];
				_historyPosition++;
				_historyLength = _historyPosition;
				_commands = [].concat(_commands);
				updateProperties();
				
				PropertyEvent.dispatchChangeList(this, ["commands", "currentCommand", "currentPosition", "historyPosition", "historyLength"], oldValues);
				
			}
		}
		
		/**
		 * Reverses the action of the last command executed.
		 */
		public function undo():Boolean
		{
			if(!canUndo) {
				return false;
			}
			
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
			if(_commands.length != 0) {
				var oldValues:Array = [_commands, _currentCommand, _currentPosition, _historyPosition, _historyLength];
				
				_commands = [];
				_currentCommand = null;
				_currentPosition = 0;
				_historyPosition = 0;
				_historyLength = 0;
				updateProperties();
				
				PropertyEvent.dispatchChangeList(this, ["commands", "currentCommand", "currentPosition", "historyPosition", "historyLength"], oldValues);
				return true;
			}
			return false;
		}
		
		/**
		 * 
		 */
		protected function updateProperties():void
		{
			var oldValues:Array = [_canUndo, _canRedo];
			
			_canUndo = Boolean(_currentPosition > 0);
			_canRedo = Boolean(_currentPosition < _commands.length);
			
			PropertyEvent.dispatchChangeList(this, ["undo", "redo"], oldValues);
		}
		
		protected function splice(startIndex:int, deleteCount:uint, ... values):void
		{
			var oldValues:Array = [_commands, _currentCommand, _currentPosition, _historyPosition, _historyLength];
			
			if(values.length == 1 && values[0] is Array) {
				values = values[0];
			}
			var shift:int = values.length - deleteCount;
			
			_commands.splice.apply(_commands, [startIndex, deleteCount].concat(values) );
			if(_currentPosition > startIndex) {
				_historyPosition += shift;
				_currentPosition += shift;
				_currentCommand = _commands[_currentPosition-1];
			}
			_historyLength += shift;
			_commands = [].concat(_commands);
			updateProperties();
			
			PropertyEvent.dispatchChangeList(this, ["commands", "currentCommand", "currentPosition", "historyPosition", "historyLength"], oldValues);
		}
		
		/**
		 * Catches asynchronous commands upon cancelation to remove from the history.
		 */
		private function onAsyncError(event:Event):void
		{
			var command:IAsyncCommand = event.target as IAsyncCommand;
			command.removeEventListener(Event.CANCEL, onAsyncError);
			asyncError = true;
			
			var index:int = _commands.indexOf(command)
			if(index != -1) {
				splice(index, 1);
			}
		}
		
	}
}
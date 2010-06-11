/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.commands
{
	import flight.events.PropertyEvent;
	import flight.list.ArrayList;
	import flight.net.ResponseStatus;
	import flight.utils.getType;
	import flight.utils.ValueObject;
	
	/**
	 * The CommandHistory executes and stores undoable commands as a history,
	 * allowing undo and redo, limiting the level of undo's, etc.
	 */
	public class CommandHistory extends ValueObject implements ICommandHistory
	{
		protected var mergingCommand:IMergingCommand;
		
		private var _canUndo:Boolean = false;
		private var _canRedo:Boolean = false;
		private var _historyLength:int = 0;
		private var _historyPosition:int = 0;
		private var _currentPosition:int = 0;			// the internal position of the _history at the present time.
		private var _undoLimit:uint = 10;				// the internal level of undo's allowed.
		private var _commands:ArrayList = new ArrayList();
		private var _currentCommand:IUndoableCommand;
		
		/**
		 * The actual list of commands, in order of occurance. This list should
		 * not be manipultated directly and should be treated as read only.
		 */
		[Bindable(event="commandsChange")]
		public function get commands():ArrayList
		{
			return _commands;
		}
		
		/**
		 * The current command in the _history, often the last command executed.
		 */
		[Bindable(event="currentCommandChange")]
		public function get currentCommand():IUndoableCommand
		{
			return _currentCommand;
		}
		
		/**
		 * Indicates whether there are commands availble to undo
		 */
		[Bindable(event="canUndoChange")]
		public function get canUndo():Boolean
		{
			return _canUndo;
		}
		
		/**
		 * Indicates whether there are commands availble to redo
		 */
		[Bindable(event="canRedoChange")]
		public function get canRedo():Boolean
		{
			return _canRedo;
		}
		
		[Bindable(event="historyLengthChange")]
		public function get historyLength():int
		{
			return _historyLength;
		}
		
		[Bindable(event="historyPositionChange")]
		public function get historyPosition():int
		{
			return _historyPosition;
		}
		
		/**
		 * The internal position of the _history at the present time.
		 */
		[Bindable(event="currentPositionChange")]
		public function get currentPosition():int
		{
			return _currentPosition;
		}
		public function set currentPosition(value:int):void
		{
			if (value > _commands.length) {
				value = _commands.length;
			} else if (value < 0) {
				value = 0;
			}
			
			if (_currentPosition == value) {
				return;
			}
			
			var oldValues:Array = [_currentCommand, _currentPosition, _historyPosition];
			
			var i:int, command:IUndoableCommand;
			if (_currentPosition > value) {
				
				for (i = _currentPosition; i > value; i--) {
					command = _commands.getItemAt(i-1) as IUndoableCommand;
					command.undo();
				}
			} else {
				
				for (i = _currentPosition; i < value; i++) {
					command = _commands.getItemAt(i) as IUndoableCommand;
					command.redo();
				}
			}
			
			_currentPosition = value;
			_historyPosition = _historyLength - (_commands.length - _currentPosition);
			_currentCommand = _commands.getItemAt(_currentPosition-1) as IUndoableCommand;
			updateProperties();
			
			PropertyEvent.dispatchChangeList(this, ["currentCommand", "currentPosition", "historyPosition"], oldValues);
		}
		
		/**
		 * The undo level of commands that will be stored in _history. Older commands
		 * will be removed from _history, freeing up memory as this limit is exceeded.
		 */
		[Bindable(event="undoLimitChange")]
		public function get undoLimit():int
		{
			return _undoLimit;
		}
		public function set undoLimit(value:int):void
		{
			if (_undoLimit == value) {
				return;
			}
			
			var oldValues:Array = [_currentPosition, _undoLimit];
			
			_undoLimit = value > 0 ? value : int.MAX_VALUE;
			_commands.removeItems(_currentPosition);
			if (_commands.length > _undoLimit) {
				_currentPosition = _undoLimit;
				_commands.removeItems(0, _commands.length - _undoLimit);
			}
			updateProperties();
			
			PropertyEvent.dispatchChangeList(this, ["currentPosition", "undoLimit"], oldValues);
		}
		
		/**
		 * Adds a command to the _history before executing it. This is how all commands should
		 * be introduced to the CommandHistory, to ensure undo can rely on an initial execution.
		 */
		public function executeCommand(command:ICommand):void
		{
			if ( !(command is IUndoableCommand) || _commands.getItemIndex(command) != -1) {
				command.execute();
				return;
			}
			
			// handle merging commands
			if (command is IMergingCommand && IMergingCommand(command).merging) {
				
				if (mergingCommand == null || getType(mergingCommand) != getType(command)) {
					mergingCommand = command as IMergingCommand;
				} else {
					
					var merged:Boolean = mergingCommand.merge(command as IMergingCommand);
					if (merged) {
						return;
					}
					
					mergingCommand = command as IMergingCommand;
				}
				
			} else {
				mergingCommand = null;
			}
			
			// execute command
			command.execute();
			
			// handle asynchronous commands
			if (command is IAsyncCommand) {
				var asyncCommand:IAsyncCommand = command as IAsyncCommand;
				if (asyncCommand.response.status == ResponseStatus.FAULT) {
					return;
				}
				
				asyncCommand.response.addFaultHandler(onAsyncFault, command);
			}
			
			// update properties
			var oldValues:Array = [_currentCommand, _historyPosition, _historyLength];
			
			_commands.removeItems(_currentPosition);
			_commands.addItem(command);
			if (_commands.length > _undoLimit) {
				oldValues.push(_currentPosition - 1);
				_currentPosition = _undoLimit;
				_commands.removeItems(0, _commands.length - _undoLimit);
			} else {
				oldValues.push(_currentPosition);
				_currentPosition++;
			}
			_currentCommand = _commands.getItemAt(_currentPosition-1) as IUndoableCommand;
			_historyPosition++;
			_historyLength = _historyPosition;
			updateProperties();
			
			PropertyEvent.dispatchChangeList(this, ["currentCommand", "historyPosition", "historyLength", "currentPosition"], oldValues);
		}
		
		/**
		 * Reverses the action of the last command executed.
		 */
		public function undo():Boolean
		{
			if (!canUndo) {
				return false;
			}
			
			mergingCommand = null;
			currentPosition--;
			return true;
		}
		
		/**
		 * Re-executes the next command in the _history through its redo method.
		 */
		public function redo():Boolean
		{
			if (!canRedo) {
				return false;
			}
			
			currentPosition++;
			return true;
		}
		
		/**
		 * Resets the merging command behavior.
		 */
		public function resetMerging():Boolean
		{
			if (mergingCommand == null) {
				return false;
			}
			
			mergingCommand = null;
			return true;
		}
		
		/**
		 * Clears all commands from the history and resets the present position to zero.
		 */
		public function clearHistory():Boolean
		{
			if (_commands.length != 0) {
				var oldValues:Array = [_currentCommand, _currentPosition, _historyPosition, _historyLength];
				
				_commands.source = [];
				_currentCommand = null;
				_currentPosition = 0;
				_historyPosition = 0;
				_historyLength = 0;
				updateProperties();
				
				PropertyEvent.dispatchChangeList(this, ["currentCommand", "currentPosition", "historyPosition", "historyLength"], oldValues);
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
			
			PropertyEvent.dispatchChangeList(this, ["canUndo", "canRedo"], oldValues);
		}
		
		protected function splice(startIndex:int, deleteCount:uint, ... values):void
		{
			var oldValues:Array = [_currentCommand, _currentPosition, _historyPosition, _historyLength];
			
			if (values.length == 1 && values[0] is Array) {
				values = values[0];
			}
			var shift:int = values.length - deleteCount;
			
			_commands.removeItems(startIndex, deleteCount);
			_commands.addItems(values, startIndex);
			
			if (_currentPosition > startIndex) {
				_historyPosition += shift;
				_currentPosition += shift;
				_currentCommand = _commands.getItemAt(_currentPosition-1) as IUndoableCommand;
			}
			_historyLength += shift;
			updateProperties();
			
			PropertyEvent.dispatchChangeList(this, ["currentCommand", "currentPosition", "historyPosition", "historyLength"], oldValues);
		}
		
		/**
		 * Catches asynchronous commands upon cancelation to remove from the history.
		 */
		private function onAsyncFault(error:Error, command:IAsyncCommand):void
		{
			var index:int = _commands.getItemIndex(command);
			if (index != -1) {
				splice(index, 1);
			}
		}
		
	}
}
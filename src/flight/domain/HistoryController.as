/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.domain
{
	import flight.binding.Bind;
	import flight.commands.CommandHistory;
	import flight.commands.ICommand;
	import flight.commands.ICommandHistory;
	import flight.errors.CommandError;
	import flight.events.PropertyEvent;
	import flight.net.Response;
	import flight.utils.Singleton;
	
	/**
	 * HistoryDomain acts as an interface to a CommandHistory.
	 * It exposes methods such as undo/redo and routes IUndoableCommands to the current history.  
	 */
	public class HistoryController extends DomainController implements ICommandHistory
	{
		private var _commandHistory:CommandHistory;
		
		public function HistoryController()
		{
			commandHistory = new CommandHistory();
			Bind.addListener(this, onHistoryChange, this, "commandHistory.canUndo");
			Bind.addListener(this, onHistoryChange, this, "commandHistory.canRedo");
			Bind.addListener(this, onHistoryChange, this, "commandHistory.undoLimit");
		}
		
		/**
		 * Shows that undo can be called successfully.
		 */
		[Bindable(event="canUndoChange")]
		public function get canUndo():Boolean
		{
			return _commandHistory.canUndo;
		}
		
		/**
		 * Shows that redo can be called successfully.
		 */
		[Bindable(event="canRedoChange")]
		public function get canRedo():Boolean
		{
			return _commandHistory.canRedo;
		}
		
		/**
		 * The limit to the length of the commandHistory; the number of commands that are stored.
		 */
		[Bindable(event="undoLimitChange")]
		public function get undoLimit():int
		{
			return _commandHistory.undoLimit;
		}
		public function set undoLimit(value:int):void
		{
			_commandHistory.undoLimit = value;
		}
		
		/**
		 * A reference to the current commandHistory.
		 */
		[Bindable(event="commandHistoryChange")]
		public function get commandHistory():CommandHistory
		{
			return _commandHistory;
		}
		public function set commandHistory(value:CommandHistory):void
		{
			if (_commandHistory == value) {
				return;
			}
			
			var oldValue:Object = _commandHistory;
			
			_commandHistory = value;
			invoker = value;
			
			PropertyEvent.dispatchChange(this, "commandHistory", oldValue, _commandHistory);
		}
		
		/**
		 * The commandHistory undo, restoring state to a certain point in time.
		 */
		public function undo():Boolean
		{
			var command:ICommand = _commandHistory.currentCommand;
			var success:Boolean = _commandHistory.undo();
			if (success) {
				dispatchResponse(getCommandType(command), new Response( new CommandError(command, "Undo action.") ));
			}
			return success;
		}
		
		/**
		 * The commandHistory redo, updating state following an undo.
		 */
		public function redo():Boolean
		{
			var success:Boolean = _commandHistory.redo();
			var command:ICommand = _commandHistory.currentCommand;
			if (success) {
				dispatchResponse(getCommandType(command), new Response(command));
			}
			return success;
		}
		
		/**
		 * Resets the merging command behavior.
		 */
		public function resetMerging():Boolean
		{
			return _commandHistory.resetMerging();
		}
		
		/**
		 * Releases all commands from the commandHistory.
		 */
		public function clearHistory():Boolean
		{
			return _commandHistory.clearHistory();
		}
		
		private function onHistoryChange(event:PropertyEvent):void
		{
			PropertyEvent.dispatchChange(this, event.property, event.oldValue, event.newValue);
		}
		
	}
}

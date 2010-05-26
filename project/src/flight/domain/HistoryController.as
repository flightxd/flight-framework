////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2009 Tyler Wright, Robert Taylor, Jacob Wright
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

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

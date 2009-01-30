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

package flight.domain
{
	import flight.commands.CommandHistory;
	import flight.commands.ICommand;
	import flight.commands.ICommandHistory;
	import flight.events.CommandEvent;
	import flight.events.PropertyChangeEvent;
	import flight.utils.Registry;
	import flight.utils.getType;
	
	import mx.binding.utils.BindingUtils;
	
	/**
	 * HistoryDomain acts as an interface to a CommandHistory.
	 * It exposes methods such as undo/redo and routes IUndoableCommands to the current history.  
	 */
	public class HistoryController extends DomainController implements ICommandHistory
	{
		private var d:HistoryControllerData;
		
		public function HistoryController()
		{
			d = Registry.getInstance(HistoryControllerData, getType(this)) as HistoryControllerData;
			
			// TODO: replace with Flight Binding and ensure binds only happen once (instead of on each Controller instance)
			BindingUtils.bindProperty(this, "canUndo", this, ["commandHistory", "canUndo"]);
			BindingUtils.bindProperty(this, "canRedo", this, ["commandHistory", "canRedo"]);
		}
		
		/**
		 * A reference to the current commandHistory.
		 */
		[Bindable(event="propertyChange", flight="true")]
		public function get commandHistory():CommandHistory
		{
			return d._commandHistory;
		}
		public function set commandHistory(value:CommandHistory):void
		{
			if(d._commandHistory == value) {
				return;
			}
			
			invoker = value;
			PropertyChangeEvent.dispatchPropertyChange(this, "commandHistory", d._commandHistory, d._commandHistory = value);
		}
		
		/**
		 * Shows that undo can be called successfully.
		 */
		[Bindable(event="propertyChange", flight="true")]
		public function get canUndo():Boolean
		{
			return d._canUndo;
		}
		/**
		 * @private 
		 */		
		public function set canUndo(value:Boolean):void
		{
			if(d._canUndo == value) {
				return;
			}
			
			PropertyChangeEvent.dispatchPropertyChange(this, "canUndo", d._canUndo, d._canUndo = value);
		}
		
		/**
		 * Shows that redo can be called successfully.
		 */
		[Bindable(event="propertyChange", flight="true")]
		public function get canRedo():Boolean
		{
			return d._canRedo;
		}
		/**
		 * @private 
		 */
		public function set canRedo(value:Boolean):void
		{
			if(d._canRedo == value) {
				return;
			}
			
			var oldValue:Boolean = d._canRedo;
			d._canRedo = value;
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
			if(success) {
				dispatchEvent(new CommandEvent(getCommandType(command), command, true));
			}
			return success;
		}
		
		/**
		 * The commandHistory redo, updating state following an undo.
		 */
		public function redo():Boolean
		{
			var success:Boolean = commandHistory.redo();
			var command:ICommand = commandHistory.currentCommand;
			if(success) {
				dispatchEvent(new CommandEvent(getCommandType(command), command, false));
			}
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
	public var _commandHistory:CommandHistory = new CommandHistory();
	public var _canUndo:Boolean = false;
	public var _canRedo:Boolean = false;
}


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
	import flash.events.Event;
	
	import flight.commands.IAsyncCommand;
	import flight.commands.ICommand;
	import flight.commands.IMergingCommand;
	import flight.commands.IUndoableCommand;
	import flight.errors.CommandError;
	import flight.events.PropertyEvent;
	import flight.utils.getClassName;
	
	/**
	 * The MacroCommand class is a single command that executes
	 * a list of many commands.
	 */
	[DefaultProperty("commands")]
	public class MacroCommand extends AsyncCommand
	{
		public var queue:Boolean = true;
		public var atomic:Boolean = true;
		
		private var currentCommand:ICommand;
		private var undone:Boolean;
		private var _commands:Array;
		private var _merging:Boolean = false;
		
		public function MacroCommand(commands:Array = null)
		{
			this.commands = commands != null ? commands : [];
		}
		
		public function get merging():Boolean
		{
			return _merging;
		}
		public function set merging(value:Boolean):void
		{
			_merging = value;
		}
		
		[ArrayElementType("flight.commands.ICommand")]
		/**
		 * The list of commands to be executed.
		 */
		public function get commands():Array
		{
			return _commands;
		}
		public function set commands(value:Array):void
		{
			if (_commands == value) {
				return;
			}
			
			var oldValue:Object = _commands;
			_commands = value;
			PropertyEvent.dispatchChange(this, "commands", oldValue, _commands);
		}
		
		/**
		 * Runs through the command list in order, executing each.
		 */
		override public function execute():void
		{
			currentCommand = null;
			executeNext();
		}
		
		/**
		 * Runs through the list of commands in reverse order, verifying that
		 * each is undable before calling undo on the individual command.
		 */
		public function undo():void
		{
			var i:int = (currentCommand != null) ? commands.indexOf(currentCommand) :
												commands.length - 1;
			if (i == commands.length-1) {
				
				for (i; i >= 0; i--) {
					var command:ICommand = commands[i];
					if (command is IUndoableCommand) {
						IUndoableCommand(command).undo();
					}
				}
				currentCommand = null;
				undone = true;
			}
		}
		
		public function redo():void
		{
			if (undone) {
				
				for (var i:int = 0; i < commands.length; i++) {
					var command:ICommand = commands[i];
					if (command is IUndoableCommand) {
						IUndoableCommand(command).redo();
					}
				}
				currentCommand = command;
				undone = false;
			}
		}
		
		public function merge(source:Object):Boolean
		{
			if (source is MacroCommand) {
				for each (var command:ICommand in MacroCommand(source).commands) {
					commands.push(command);
				}
			} else if (source is ICommand) {
				commands.push(source);
			} else {
				return false;
			}
			
			return true;
		}
		
		protected function executeNext(command:ICommand = null):void
		{
			var i:int = 0;
			
			if (command != null) {
				
				i = commands.indexOf(command);
				if (i == -1) {
					throw new Error("Comand " + getClassName(command) + " does not exist in macro " + getClassName(this));
				}
				
			} else if (currentCommand != null) {
				i = commands.indexOf(currentCommand) + 1;
			}
			
			
			if (i < commands.length) {
				
				currentCommand = commands[i];
				
				if (currentCommand is IAsyncCommand && queue) {
					var asyncCommand:IAsyncCommand = currentCommand as IAsyncCommand;
					// TODO: determine if this is the right method to intercept automatic command execution for custom direction
					// or if a MacroCommand.pause() would be a better implementation
					if (!asyncCommand.hasEventListener(Event.COMPLETE)) {
						asyncCommand.addEventListener(Event.COMPLETE, onAsyncComplete)
						asyncCommand.response.addFaultHandler(onCommandFault);
					}
					asyncCommand.execute();
				} else {
					try {
						currentCommand.execute();
						executeNext();
					} catch(error:CommandError) {
						onCommandFault(error);
					}
				}
			} else {
				response.complete(this);
			}
		}
		
		private function onAsyncComplete(event:Event):void
		{
			executeNext();
		}
		
		private function onCommandFault(error:Error):void
		{
			if (atomic) {
				response.cancel(error);
			} else {
				executeNext();
			}
		}
		
	}
}

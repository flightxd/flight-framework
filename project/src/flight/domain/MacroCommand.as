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
	import flight.commands.IUndoableCommand;
	import flight.events.PropertyEvent;
	
	/**
	 * The MacroCommand class is a single command that executes
	 * a list of many commands.
	 */
	[DefaultProperty("commands")]
	public class MacroCommand extends AsyncCommand implements IUndoableCommand
	{
		public var queue:Boolean = true;
		
		private var currentCommand:ICommand;
		private var undone:Boolean;
		private var _commands:Array;
		
		public function MacroCommand(commands:Array = null)
		{
			this.commands = commands != null ? commands : [];
		}
		
		/**
		 * The list of commands to be executed.
		 */
		public function get commands():Array
		{
			return _commands;
		}
		public function set commands(value:Array):void
		{
			if(_commands != value) {
				var oldValue:Object = _commands;
				_commands = value;
				PropertyEvent.dispatchChange(this, "commands", oldValue, _commands);
			}
		}
		
		/**
		 * Runs through the command list in order, executing each.
		 */
		override public function execute():Boolean
		{
			currentCommand = null;
			return executeNext();
		}
		
		/**
		 * Runs through the list of commands in reverse order, verifying that
		 * each is undable before calling undo on the individual command.
		 */
		public function undo():void
		{
			var i:int = (currentCommand != null) ? commands.indexOf(currentCommand) :
												commands.length - 1;
			if(i == commands.length-1) {
				
				for(i; i >= 0; i--) {
					var command:ICommand = commands[i];
					if(command is IUndoableCommand) {
						IUndoableCommand(command).undo();
					}
				}
				currentCommand = null;
				undone = true;
			}
		}
		
		public function redo():void
		{
			if(undone) {
				
				for(var i:int = 0; i < commands.length; i++) {
					var command:ICommand = commands[i];
					if(command is IUndoableCommand) {
						IUndoableCommand(command).redo();
					}
				}
				currentCommand = command;
				undone = false;
			}
		}
		
		protected function executeNext(event:Event = null):Boolean
		{
			var i:int = (currentCommand != null) ? commands.indexOf(currentCommand) + 1 : 0;
			if(i < commands.length) {
				
				currentCommand = commands[i];
				
				if(currentCommand is IAsyncCommand && queue) {
					
					var asyncCommand:IAsyncCommand = currentCommand as IAsyncCommand;
					if(!asyncCommand.hasEventListener(Event.COMPLETE) ) {
						asyncCommand.addEventListener(Event.COMPLETE, executeNext);
						asyncCommand.addEventListener(Event.CANCEL, dispatchCancel);
					}
					
					return asyncCommand.execute();
				} else if( currentCommand.execute() ) {
					return executeNext();
				} else {
					return false;
				}
			}
			
			dispatchComplete();
			return true;
		}
		
	}
}

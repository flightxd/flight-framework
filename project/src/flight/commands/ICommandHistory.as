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

package flight.commands
{
	/**
	 * The ICommandHistory is the basic interface for all histories that execute and store
	 * undoable commands, allowing undo and redo, limiting the level of undo's, etc.
	 */
	public interface ICommandHistory extends ICommandInvoker
	{
		/**
		 * Shows that undo can be called successfully.
		 */
		function get canUndo():Boolean;
		
		/**
		 * Shows that redo can be called successfully.
		 */
		function get canRedo():Boolean;
		
		/**
		 * The limit to the length of the history; the number of commands that are stored.
		 */
		function get undoLimit():int;
		function set undoLimit(value:int):void;
		
		/**
		 * The history undo, restoring state to a certain point in time.
		 */
		function undo():Boolean;
		
		/**
		 * The history redo, updating state following an undo.
		 */
		function redo():Boolean;
		
		/**
		 * Resets the merging command behavior.
		 */
		function resetMerging():Boolean;
		
		/**
		 * Releases all commands from the history.
		 */
		function clearHistory():Boolean;
	}
}
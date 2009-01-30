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
	/**
	 * An interface for commands that support undo and redo and can be combined into
	 * one undoable action.
	 */
	public interface ICombinableCommand extends IUndoableCommand
	{
		/**
		 * Flags the CommandHistory to treat this as a combining command.
		 */
		function get combining():Boolean;
		
		/**
		 * Gives the first executed command the opportunity to combine itself with
		 * another combinable command which was called later and returns the success
		 * of the combination. If the combination fails, will execute the combining
		 * command as a new command.
		 */
		 function combine(command:ICombinableCommand):Boolean;
	}
}
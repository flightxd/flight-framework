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
	 * The ICommandFactory establishes the core methods for storing and retrieving
	 * ICommand classes and their instances; based on the Factory Design Pattern.
	 * Used by plugin architectures that gain flexibility by hiding implementation.
	 */
	public interface ICommandFactory
	{
		/**
		 * Registers a command class with a unique id for later access.
		 */
		function addCommand(type:String, commandClass:Class, propertyList:Array = null):void;
		
		/**
		 * Retrieves the command class registered with this type.
		 */
		function getCommand(type:String):Class;
		
		/**
		 * Primary method responsible for command class instantiation, hiding the details
		 * of class inheritance, implementation, origin, etc. Allows instantiation parameters.
		 */
		function createCommand(type:String, properties:Object = null):ICommand;
	}
}
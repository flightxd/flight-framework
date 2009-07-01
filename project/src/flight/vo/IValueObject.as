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

package flight.vo
{
	/**
	 * IValueObject is a common interface for many data structures, allowing
	 * complex objects to be treated as simple types, as value versus reference.
	 * 
	 * <p>A Value Object is an object that can be compared by the values of its
	 * properties rather than its identiy. Two Value Objects may be equal
	 * because their data is identical, even if they are individual reference
	 * objects in ActionScript. Through implementing equals() two Value Objects
	 * can be compared by their data, while clone() allows Value Objects to be
	 * passed by value (as copies).<p>
	 * 
	 * @see		#equals
	 * @see		#clone
	 */
	public interface IValueObject
	{
		/**
		 * Evaluates the equality of another object of the same type, based on
		 * its properties.
		 * 
		 * @param	value			The target of the comparison.
		 */
		function equals(value:Object):Boolean;
		
		/**
		 * Returns a new object that is an exact copy of this object.
		 * 
		 * @return					The replicated object.
		 */
		function clone():Object;
	}
}

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

package flight.utils
{
	import flash.utils.ByteArray;
	
	import flight.events.Dispatcher;
	
	/**
	 * ValueObject is a convenient base class for data-rich objects that can be
	 * compared, copied and serialized. ValueObject offers a static
	 * implementation of the methods equals() and clone() for use throughout
	 * the system.
	 */
	public class ValueObject extends Dispatcher implements IValueObject
	{
		public function ValueObject()
		{
			Type.registerType(this);
		}
		
		/**
		 * Evaluates the equality of another object of the same type, based on
		 * its properties.
		 * 
		 * @param	value			The target of the comparison.
		 */
		public function equals(value:Object):Boolean
		{
			return ValueObject.equals(this, value);
		}
		
		/**
		 * Returns a new object that is an exact copy of this object.
		 * 
		 * @return					The replicated object.
		 */
		public function clone():Object
		{
			return ValueObject.clone(this);
		}
		
		// ========== Static Methods ========== //
		
		/**
		 * Evaluates the equality of two objects of the same type, based on
		 * their properties. This method uses ActionScript's serialization
		 * methods for string comparison and provides a deep comparison
		 * (matching values on the entire structure). This method is not as
		 * fast as most custom implementations.
		 * 
		 * @param	value1			The first target of the comparison.
		 * @param	value1			The second target of the comparison.
		 * 
		 * @see		flash.utils.ByteArray#writeObject
		 */
		public static function equals(value1:Object, value2:Object):Boolean
		{
			if (value1 == value2) {
				return true;
			}
			
			Type.registerType(value1);
			
			var so1:ByteArray = new ByteArray();
	       	so1.writeObject(value1);
	        
			var so2:ByteArray = new ByteArray();
        	so2.writeObject(value2);
			
			return Boolean(so1.toString() == so2.toString());
		}
		
		/**
		 * Returns a new object that is an exact copy of the target object. This
		 * method uses ActionScript's serialization methods to provide a deep
		 * copy (replication of the entire structure). This method is not as
		 * fast as most custom implementations.
		 * 
		 * @param	value			The target object to copy.
		 * @return					The replicated object.
		 * 
		 * @see		flash.utils.ByteArray#writeObject
		 * @see		flash.utils.ByteArray#readObject
		 */
		public static function clone(value:Object):Object
		{
			Type.registerType(value);
			
			var so:ByteArray = new ByteArray();
	        so.writeObject(value);
	        
	        so.position = 0;
	        return so.readObject();
		}
		
	}
}
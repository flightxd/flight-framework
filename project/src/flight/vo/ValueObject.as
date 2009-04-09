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

package flight.vo
{
	import flash.utils.ByteArray;
	
	import flight.events.FlightDispatcher;
	import flight.utils.Type;
	
	public class ValueObject extends FlightDispatcher implements IValueObject
	{
		
		public function equals(value:Object):Boolean
		{
			return ValueObject.equals(this, value);
		}
		
		public function clone():Object
		{
			return ValueObject.clone(this);
		}
		
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
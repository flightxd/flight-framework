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

package flight.events
{
	import flash.events.Event;

	public class ListEvent extends Event
	{
		public static const LIST_CHANGE:String = "listChange";
		
		private var _kind:String;
		private var _items:*;
		private var _location1:int;
		private var _location2:int;
		
		public function ListEvent(type:String, kind:String, items:* = null, location1:int = -1, location2:int = -1)
		{
			super(type);
			
			_kind = kind;
			_items = items;
			_location1 = location1;
			_location2 = location2;
		}
		
		public function get kind():String
		{
			return _kind;
		}
		
		public function get items():*
		{
			return _items;
		}
		
		public function get location1():int
		{
			return _location1;
		}
		
		public function get location2():int
		{
			return _location2;
		}
		
		override public function clone():Event
		{
			return new ListEvent(type, _kind, _items, _location1, _location2);
		}
	}
}
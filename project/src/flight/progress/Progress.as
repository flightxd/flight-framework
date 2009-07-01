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

package flight.progress
{
	import flight.events.FlightDispatcher;
	import flight.events.PropertyEvent;
	
	public class Progress extends FlightDispatcher implements IProgress
	{
		private var _position:Number = 0;
		private var _percent:Number = 0;
		private var _length:Number = 1;
		
		[Bindable(event="positionChange")]
		public function get position():Number
		{
			return _position;
		}
		public function set position(value:Number):void
		{
			value = Math.max(0, Math.min(_length, value));
			if (_position == value) {
				return;
			}
			
			var oldValues:Array = [_position, _percent];
			_position = value;
			_percent = _position / _length;
			
			PropertyEvent.dispatchChangeList(this, ["position", "percent"], oldValues);
		}
		
		[Bindable(event="percentChange")]
		public function get percent():Number
		{
			return _percent;
		}
		public function set percent(value:Number):void
		{
			value = Math.max(0, Math.min(1, value));
			if (_percent == value) {
				return;
			}
			
			var oldValues:Array = [_percent, _position];
			_percent = value;
			_position = _percent * _length;
			
			PropertyEvent.dispatchChangeList(this, ["percent", "position"], oldValues);
		}
		
		[Bindable(event="lengthChange")]
		public function get length():Number
		{
			return _length;
		}
		public function set length(value:Number):void
		{
			value = Math.max(0, value);
			if (_length == value) {
				return;
			}
			
			var oldValue:Object = _length;
			_length = value;
			if (_position > _length) {
				position = _length;
			}
			propertyChange("length", oldValue, _length);
		}
		
	}
}
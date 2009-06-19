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

package flight.position
{
	import flight.events.FlightDispatcher;
	import flight.events.PropertyEvent;
	
	public class Position extends FlightDispatcher implements IPosition
	{
		private var _position:Number = 0;
		private var _percent:Number = 0;
		private var _min:Number = 0;
		private var _max:Number = 1;
		private var _size:Number = 0;
		private var _interval:Number = 0.01;
		private var _intervalLarge:Number = 0.1;
		
		public function get position():Number
		{
			return _position;
		}
		public function set position(value:Number):void
		{
			value = Math.max(_min, Math.min(_max - _size, value));
			if (_position == value) {
				return;
			}
			
			var oldValues:Array = [_position, _percent];
			_position = value;
			var space:Number = (_max - _size - _min);
			_percent = space == 0 ? 1 : _position / space;
			
			PropertyEvent.dispatchChangeList(this, ["position", "percent"], oldValues);
		}
		
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
			var space:Number = (_max - _size - _min);
			_position = _min + _percent * space;
			
			PropertyEvent.dispatchChangeList(this, ["percent", "position"], oldValues);
		}
		
		public function get min():Number
		{
			return _min;
		}
		public function set min(value:Number):void
		{
			if (_min == value) {
				return;
			}
			
			var oldValues:Array = [_min];
			var properties:Array = ["min"];
			_min = value;
			
			if (_max < _min) {
				oldValues.push(_max);
				properties.push("max");
				_max = _min;
			}
			if (_size > _max - _min) {
				oldValues.push(_size);
				properties.push("size");
				_size = _max - _min;
			}
			
			position = position;
			PropertyEvent.dispatchChangeList(this, properties, oldValues);
		}
		
		public function get max():Number
		{
			return _max;
		}
		public function set max(value:Number):void
		{
			if (_max == value) {
				return;
			}
			
			var oldValues:Array = [_max];
			var properties:Array = ["max"];
			_max = value;
			
			if (_min > _max) {
				oldValues.push(_min);
				properties.push("min");
				_min = _max;
			}
			if (_size > _max - _min) {
				oldValues.push(_size);
				properties.push("size");
				_size = _max - _min;
			}
			
			position = position;
			PropertyEvent.dispatchChangeList(this, properties, oldValues);
		}
		
		public function get size():Number
		{
			return _size;
		}
		public function set size(value:Number):void
		{
			value = Math.min(_max - _min, value);
			if (_size == value) {
				return;
			}
			
			var oldValue:Object = _size;
			_size = value;
			propertyChange("size", oldValue, _size);
		}
		
		public function get interval():Number
		{
			return _interval;
		}
		public function set interval(value:Number):void
		{
			if (_interval == value) {
				return;
			}
			
			var oldValue:Object = _interval;
			_interval = value;
			propertyChange("interval", oldValue, _interval);
		}
		
		public function get intervalLarge():Number
		{
			return _intervalLarge;
		}
		public function set intervalLarge(value:Number):void
		{
			if (_intervalLarge == value) {
				return;
			}
			
			var oldValue:Object = _intervalLarge;
			_intervalLarge = value;
			propertyChange("intervalLarge", oldValue, _intervalLarge);
		}
		
		public function increment():void
		{
			position += interval;
		}
		
		public function decrement():void
		{
			position -= interval;
		}
		
		public function incrementLarge():void
		{
			position += intervalLarge;
		}
		
		public function decrementLarge():void
		{
			position -= intervalLarge;
		}
	}
}
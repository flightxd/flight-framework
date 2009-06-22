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

package flight.progress
{
	import flight.events.FlightDispatcher;
	import flight.events.PropertyEvent;
	
	public class Position extends FlightDispatcher implements IPosition
	{
		private var _position:Number = 0;
		private var _percent:Number = 0;
		private var _length:Number = 1;
		private var _min:Number = 0;
		private var _max:Number = 1;
		private var _positionSize:Number = 0;
		private var _stepSize:Number = 0.01;
		private var _skipSize:Number = 0.1;
		
		[Bindable(event="positionChange")]
		public function get position():Number
		{
			return _position;
		}
		public function set position(value:Number):void
		{
			value = Math.max(_min, Math.min(_max - _positionSize, value));
			if (_position == value) {
				return;
			}
			
			var oldValues:Array = [_position, _percent];
			_position = value;
			var space:Number = (_max - _positionSize - _min);
			_percent = space == 0 ? 1 : _position / space;
			
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
			var space:Number = (_max - _positionSize - _min);
			_position = _min + _percent * space;
			
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
			
			var oldValues:Array = [_length, _max];
			_length = value;
			_max = _min + _positionSize + _length;
			
			position = position;
			PropertyEvent.dispatchChangeList(this, ["length", "max"], oldValues);
		}
		
		[Bindable(event="minChange")]
		public function get min():Number
		{
			return _min;
		}
		public function set min(value:Number):void
		{
			if (_min == value) {
				return;
			}
			
			var oldValues:Array = [_min, _length];
			var properties:Array = ["min", "length"];
			_min = value;
			
			if (_max < _min) {
				oldValues.push(_max);
				properties.push("max");
				_max = _min;
			}
			if (_positionSize > _max - _min) {
				oldValues.push(_positionSize);
				properties.push("positionSize");
				_positionSize = _max - _min;
			}
			_length = _max - _positionSize - _min;
			
			position = position;
			PropertyEvent.dispatchChangeList(this, properties, oldValues);
		}
		
		[Bindable(event="maxChange")]
		public function get max():Number
		{
			return _max;
		}
		public function set max(value:Number):void
		{
			if (_max == value) {
				return;
			}
			
			var oldValues:Array = [_max, _length];
			var properties:Array = ["max", "length"];
			_max = value;
			
			if (_min > _max) {
				oldValues.push(_min);
				properties.push("min");
				_min = _max;
			}
			if (_positionSize > _max - _min) {
				oldValues.push(_positionSize);
				properties.push("positionSize");
				_positionSize = _max - _min;
			}
			_length = _max - _positionSize - _min;
			
			position = position;
			PropertyEvent.dispatchChangeList(this, properties, oldValues);
		}
		
		[Bindable(event="positionSizeChange")]
		public function get positionSize():Number
		{
			return _positionSize;
		}
		public function set positionSize(value:Number):void
		{
			value = Math.min(_max - _min, value);
			if (_positionSize == value) {
				return;
			}
			
			var oldValues:Array = [_positionSize, _length];
			_positionSize = value;
			_length = _max - _positionSize - _min;
			PropertyEvent.dispatchChangeList(this, ["positionSize", "length"], oldValues);
		}
		
		[Bindable(event="stepSizeChange")]
		public function get stepSize():Number
		{
			return _stepSize;
		}
		public function set stepSize(value:Number):void
		{
			if (_stepSize == value) {
				return;
			}
			
			var oldValue:Object = _stepSize;
			_stepSize = value;
			propertyChange("stepSize", oldValue, _stepSize);
		}
		
		[Bindable(event="skipSizeChange")]
		public function get skipSize():Number
		{
			return _skipSize;
		}
		public function set skipSize(value:Number):void
		{
			if (_skipSize == value) {
				return;
			}
			
			var oldValue:Object = _skipSize;
			_skipSize = value;
			propertyChange("skipSize", oldValue, _skipSize);
		}
		
		public function forward():void
		{
			position += stepSize;
		}
		
		public function backward():void
		{
			position -= stepSize;
		}
		
		public function skipForward():void
		{
			position += skipSize;
		}
		
		public function skipBackward():void
		{
			position -= skipSize;
		}
	}
}

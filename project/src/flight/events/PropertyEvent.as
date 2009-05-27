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

package flight.events
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class PropertyEvent extends Event
	{
		public static const _CHANGE:String = "Change";
		public static const PROPERTY_CHANGE:String = "property" + _CHANGE;
		
		/**
		 * 
		 */
		public static function dispatchChange(target:IEventDispatcher, property:String, oldValue:Object, newValue:Object):void
		{
			if ( target.hasEventListener(property + _CHANGE) ) {
				var event:PropertyEvent = getPropertyEvent(target, property + _CHANGE, property, oldValue, newValue);
				target.dispatchEvent(event);
				releasePropertyEvent(event);
			}
			
			if ( target.hasEventListener(PROPERTY_CHANGE) ) {
				event = getPropertyEvent(target, PROPERTY_CHANGE, property, oldValue, newValue);
				target.dispatchEvent(event);
				releasePropertyEvent(event);
			}
		}
		
		/**
		 * 
		 */
		public static function dispatchChangeList(target:IEventDispatcher, properties:Array, oldValues:Array):void
		{
			for (var i:int = 0; i < properties.length; i++) {
				var property:String = properties[i];
				var oldValue:Object = oldValues[i];
				var newValue:Object = target[property];
				if (oldValue != newValue || newValue is Array) {
			 		dispatchChange(target, property, oldValue, newValue);
			 	}
	 		}
		}
		
		// cache of property event objects
		private static var queue:Array = [];
		private static function getPropertyEvent(target:IEventDispatcher, type:String, property:String, oldValue:Object, newValue:Object):PropertyEvent
		{
			if (queue.length == 0) {
				return new PropertyEvent(type, property, oldValue, newValue);
			}
			
			var event:PropertyEvent = queue.pop();
				event._property = property;
				event._oldValue = oldValue;
				event._newValue = newValue;
				event._target = target;
			return event;
		}
		
		private static function releasePropertyEvent(event:PropertyEvent):void
		{
			event._newValue = null;
			event._oldValue = null;
			event._property = null;
			queue.push(event);
		}
		
		private var _property:String;
		private var _oldValue:Object;
		private var _newValue:Object;
		private var _target:*;
		
		public function PropertyEvent(type:String, property:String, oldValue:Object, newValue:Object)
		{
			super(type);
			_property = property;
			_oldValue = oldValue;
			_newValue = newValue;
		}
		
		public function get property():String
		{
			return _property;
		}
		
		public function get oldValue():Object
		{
			return _oldValue;
		}
		
		public function get newValue():Object
		{
			return _newValue;
		}
		
		override public function get target():Object
		{
			return _target || super.target;
		}
		
		override public function get currentTarget():Object
		{
			return _target || super.currentTarget;
		}
		
		/**
		 * Returns this instance of PropertyEvent rather than creating a new
		 * copy. Because of the frequency of these type of events in the system
		 * the Event objects are pooled and reused to increase performance and
		 * reduce strain on the garabage collection. PropertyEvent's should
		 * never be explicitly re-dispatched as this will throw off the current
		 * event cycle.
		 */
		override public function clone():Event
		{
			return this;
		}
	}
}
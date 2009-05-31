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
	
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	public class PropertyEvent extends PropertyChangeEvent
	{
		public static const _CHANGE:String = "Change";
		public static const PROPERTY_CHANGE:String = "property" + _CHANGE;
		
		/**
		 * 
		 */
		public static function dispatchChange(source:IEventDispatcher, property:Object, oldValue:Object, newValue:Object):void
		{
			if ( source.hasEventListener(property + _CHANGE) ) {
				var event:PropertyEvent = getPropertyEvent(source, property + _CHANGE, property, oldValue, newValue);
				source.dispatchEvent(event);
				releasePropertyEvent(event);
			}
			
			if ( source.hasEventListener(PROPERTY_CHANGE) ) {
				event = getPropertyEvent(source, PROPERTY_CHANGE, property, oldValue, newValue);
				source.dispatchEvent(event);
				releasePropertyEvent(event);
			}
		}
		
		/**
		 * 
		 */
		public static function dispatchChangeList(target:IEventDispatcher, properties:Array, oldValues:Array):void
		{
			for (var i:int = 0; i < properties.length; i++) {
				var property:Object = properties[i];
				var oldValue:Object = oldValues[i];
				var newValue:Object = target[property];
				if (oldValue != newValue || newValue is Array) {
			 		dispatchChange(target, property, oldValue, newValue);
			 	}
	 		}
		}
		
		// cache of property event objects
		private static var cache:Array = [];
		private static function getPropertyEvent(source:IEventDispatcher, type:String, property:Object, oldValue:Object, newValue:Object):PropertyEvent
		{
			if (cache.length == 0) {
				return new PropertyEvent(type, property, oldValue, newValue);
			}
			
			var event:PropertyEvent = cache.pop();
				event.property = property;
				event.oldValue = oldValue;
				event.newValue = newValue;
				event.source = source;
			return event;
		}
		
		private static function releasePropertyEvent(event:PropertyEvent):void
		{
			event.property = null;
			event.oldValue = null;
			event.newValue = null;
			event.source = null;
			cache.push(event);
		}
		
		private var _target:Object;
		
		public function PropertyEvent(type:String, property:Object, oldValue:Object, newValue:Object)
		{
			super(type, false, false, PropertyChangeEventKind.UPDATE, property, oldValue, newValue);
		}
		
		override public function get target():Object
		{
			if (source == null) {
				source = super.target;
			}
			return source;
		}
		
		override public function get currentTarget():Object
		{
			if (source == null) {
				source = super.currentTarget;
			}
			return source;
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
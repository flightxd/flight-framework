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
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class FlightDispatcher implements IEventDispatcher
	{
		protected var dispatcher:EventDispatcher;
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if (dispatcher == null) {
				dispatcher = new EventDispatcher(this);
			}
			
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if (dispatcher != null) {
				dispatcher.removeEventListener(type, listener, useCapture);
			}
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			if (dispatcher != null && dispatcher.hasEventListener(event.type)) {
				return dispatcher.dispatchEvent(event);
			}
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			if (dispatcher != null) {
				return dispatcher.hasEventListener(type);
			}
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			if (dispatcher != null) {
				return dispatcher.willTrigger(type);
			}
			return false;
		}
		
		protected function dispatch(type:String):Boolean
		{
			if (dispatcher != null && dispatcher.hasEventListener(type)) {
				return dispatcher.dispatchEvent( new Event(type) );
			}
			return false;
		}
		
		protected function propertyChange(property:String, oldValue:Object, newValue:Object):void
		{
			PropertyEvent.dispatchChange(this, property, oldValue, newValue);
		}
	}
}
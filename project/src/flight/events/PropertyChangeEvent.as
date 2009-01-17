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
	
	public class PropertyChangeEvent extends Event
	{
		public static const _CHANGE:String = "Change";
		public static const PROPERTY_CHANGE:String = "property" + _CHANGE;
		
		public static function dispatchPropertyChange(target:IEventDispatcher, property:Object,
													  oldValue:Object, newValue:Object):void
		{
			if( target.hasEventListener(property + _CHANGE) ) {
				target.dispatchEvent( new PropertyChangeEvent(property + _CHANGE, property, oldValue, newValue) );
			}
			
			if( target.hasEventListener(PROPERTY_CHANGE) ) {
				target.dispatchEvent( new PropertyChangeEvent(PROPERTY_CHANGE, property, oldValue, newValue) );
			}
		}
		
		private var _property:Object;
		private var _oldValue:Object;
		private var _newValue:Object;
		
		public function PropertyChangeEvent(type:String, property:Object, oldValue:Object, newValue:Object)
		{
			super(type);
			_property = property;
			_oldValue = oldValue;
			_newValue = newValue;
		}
		
		public function get property():Object
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
		
	}
}
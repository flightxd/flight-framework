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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.*;
	
	import flight.events.ValueObjectEditorEvent;
	import flight.utils.Type;
	
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	[Bindable("propertyChange")]
	dynamic public class ValueObjectEditor extends Proxy implements IEventDispatcher
	{
		protected var eventDispatcher:EventDispatcher;
		
		private var _copy:IValueObject;
		private var _source:IValueObject;		
		private var _props:Array;
		private var _lastModified:Boolean;
		
		public function ValueObjectEditor( value:IValueObject )
		{
			_source = value;
			_copy = _source.clone() as IValueObject;
			_props = new Array();
			
			eventDispatcher = new EventDispatcher(this);
					
			var propList:XMLList = Type.describeProperties( value );
				propList = propList.(child("metadata").(@name == "Transient").length() == 0)

			for each(var prop:XML in propList) {			
				var name:String = prop.@name;
				_props.push(name);
			}
		}
		
		public function get modified():Boolean
		{
			return !_copy.equals(_source);
		}
						
		public function get source():IValueObject
		{
			return _source;
		}
		
		public function revert():void
		{
			
			merge ( this, _source ); 
			
			dispatchEvent(new ValueObjectEditorEvent(ValueObjectEditorEvent.REVERT));
		}
		
		public function commit( ):void
		{
			// forces modified property change to fire
			_lastModified = !_lastModified;
			
			merge ( _source, _copy ); 
			
			dispatchEvent(new ValueObjectEditorEvent(ValueObjectEditorEvent.COMMIT));
			dispatchModifyEvent();
		}
		
		public static function merge(target:Object, source:Object ):void
		{
			var propList:XMLList = Type.describeProperties( source );
				propList = propList.(child("metadata").(@name == "Transient").length() == 0)
			
			// copy over class variables
			for each(var prop:XML in propList) {
				
				var name:String = prop.@name;
				if(name in target && source[name] !== undefined) {
					target[name] = source[name];
				}
			}
			
			// copy over dynamic properties
			for(name in source) {
				if(name in target && source[name] !== undefined) {
					target[name] = source[name];
				}
			}
		}
				
		public function toString():String
		{
			return String(_copy);
		}
		
		private function dispatchModifyEvent():void
		{
			var kind:String = PropertyChangeEventKind.UPDATE;
			var modify:Boolean = modified;
			if(_lastModified !== modify) {
				_lastModified = modify;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, kind, 'modified', !modify, modify, this));
			}
		}
		
		/**
		 * Flash Proxy methods
		 */
		
		override flash_proxy function callProperty(methodName:*, ... args):*
		{
			return _copy[methodName.localName].apply(_copy, args);
		}
		
		override flash_proxy function hasProperty(name:*):Boolean 
		{
			return name in _copy;
		}
		
		override flash_proxy function getProperty(name:*):* 
		{
			return _copy[name];
		}
	
		override flash_proxy function setProperty(name:*, value:*):void 
		{
			var oldValue:* = _copy[name];
			_copy[name] = value;
			
			var kind:String = PropertyChangeEventKind.UPDATE;
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, kind, name, oldValue, value, this));
			
			var modify:Boolean = modified;
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, kind, 'modified', !modify, modify, this));
			
			// Currently produces a bug
			//PropertyEvent.dispatchChange(this, name, oldValue, value);
		}
		
		override flash_proxy function deleteProperty(name:*):Boolean 
		{
			return delete _copy[name];
		}
		
		override flash_proxy function nextNameIndex (index:int):int 
		{
		    if (index < _props.length)
		        return index + 1;
		    return 0;
		}
		 
		override flash_proxy function nextName(index:int):String {
		    return _props[index - 1];
		}
	
		override flash_proxy function nextValue(index:int):* 
		{ 
			return _copy[_props[index - 1]];
		}
		
		/**
		 * Event Dispatcher methods
		 */

		public function hasEventListener(type:String):Boolean
		{
			return eventDispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return eventDispatcher.willTrigger(type);
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false):void
		{
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return eventDispatcher.dispatchEvent(event);
		}		
	}
}
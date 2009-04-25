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

package flight.utils
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import flight.events.FlightDispatcher;
	import flight.events.PropertyEvent;
	import flight.vo.IValueObject;
	import flight.vo.ValueObject;
	
	import mx.core.IMXMLObject;
	import mx.events.PropertyChangeEvent;
	
	public class ObjectEditor extends FlightDispatcher implements IMXMLObject
	{
		private var _value:Object;
		private var _source:Object;
		
		[Bindable(event="modifiedChange")]
		public function get modified():Boolean
		{
			return (_source is IValueObject) ? !IValueObject(_source).equals(_value)
											 : !ValueObject.equals(_source, _value);
		}
		
		[Bindable(event="valueChange")]
		public function get value():Object
		{
			return _value;
		}
		
		[Bindable(event="sourceChange")]
		public function get source():Object
		{
			return _source;
		}
		public function set source(value:Object):void
		{
			if (_source == value) {
				return;
			}
			var oldValues:Array = [modified, _value, _source];
			
			if (_source != null) {
				if (_source is IEventDispatcher) {
					IEventDispatcher(_source).removeEventListener(PropertyEvent.PROPERTY_CHANGE, onChange);
					IEventDispatcher(_value).removeEventListener(PropertyEvent.PROPERTY_CHANGE, onChange);
				}
				
				_value = null;
				if (editors[_source] == this) {
					delete editors[_source];
				}
			}
			
			_source = value;
			
			if (_source != null) {
				if (editors[_source] != null) {
					_value = editors[_source]._value;
				} else {
					editors[_source] = this;
					_value = (_source is IValueObject) ? IValueObject(_source).clone()
													   : ValueObject.clone(_source);
				}
				
				if (_source is IEventDispatcher) {
					IEventDispatcher(_source).addEventListener(PropertyEvent.PROPERTY_CHANGE, onChange, false, 0, true);
					IEventDispatcher(_value).addEventListener(PropertyEvent.PROPERTY_CHANGE, onChange, false, 0, true);
				}
			}
			
			PropertyEvent.dispatchChangeList(this, ["modified", "value", "source"], oldValues);
		}
		
		public function ObjectEditor(source:Object = null)
		{
			this.source = source;
		}
		
		public function commit():void
		{
			merge(_value, _source);
			source = null;
		}
		
		public function revert():void
		{
			merge(_source, _value);
		}
		
		public function cancel():void
		{
			source = null;
		}
		
		public function refresh():void
		{
			PropertyEvent.dispatchChange(this, "modified", null, modified);
		}
		
		public function initialized(document:Object, id:String):void
		{
			if (id != null && _source != null) {
				document[id] = edit(_source);
			}
		}
		
		private function onChange(event:PropertyChangeEvent):void
		{
			refresh();
		}
		
		
		private static var editors:Dictionary = new Dictionary(true);
		public static function edit(source:Object):ObjectEditor
		{
			if (editors[source] == null) {
				editors[source] = new ObjectEditor(source);
			}
			return editors[source];
		}
		
		public static function merge(source:Object, target:Object):void
		{
			var name:String;
			var propList:XMLList = Type.describeProperties( source );
				propList = propList.(child("metadata").(@name == "Transient").length() == 0);
			
			// copy over class properties
			for each (var prop:XML in propList) {
				name = prop.@name;
				if (name in target && source[name] !== undefined) {
					if (target[name] is IValueObject && source[name] is IValueObject) {
						merge(target[name], source[name]);
					} else {
						target[name] = source[name];
					}
				}
			}
			
			// copy over dynamic properties
			for (name in source) {
				if (name in target && source[name] !== undefined) {
					if (target[name] is IValueObject && source[name] is IValueObject) {
						merge(target[name], source[name]);
					} else {
						target[name] = source[name];
					}
				}
			}
		}
		
	}
}

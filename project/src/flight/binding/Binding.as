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

package flight.binding
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import flight.events.PropertyEvent;
	import flight.utils.Type;
	import flight.utils.getClassName;
	import flight.utils.getType;
	
	[Event(name="propertyChange", type="flight.events.PropertyEvent")]
	
	/**
	 * 
	 */
	public class Binding extends EventDispatcher
	{
		public var applyOnly:Boolean = false;
		
		private var indicesIndex:Dictionary = new Dictionary(true);
		private var bindIndex:Dictionary = new Dictionary(true);
		
		private var explicitValue:Object;
		private var updating:Boolean;
		private var _value:Object;
		private var _property:String;
		private var _sourcePath:Array;
		
		/**
		 * 
		 */
		public function Binding(source:Object = null, sourcePath:String = null)
		{
			reset(source, sourcePath);
		}
		
		/**
		 * 
		 */
		public function get property():String
		{
			return _property;
		}
		
		/**
		 * 
		 */
		public function get sourcePath():String
		{
			return _sourcePath.join(".");
		}
		
		/**
		 * 
		 */
		[Bindable(event="propertyChange", flight="false")]
		public function get value():Object
		{
			return _value;
		}
		public function set value(value:Object):void
		{
			if(_value == value) {
				return;
			}
			
			explicitValue = value;
			var source:Object = getSource(_sourcePath.length - 1);
			if(source != null) {
				source[property] = value;
			}
		}
		
		/**
		 * 
		 */
		public function bind(target:Object, property:String):Boolean
		{
			var bindList:Array = bindIndex[target];
			if(bindList == null) {
				bindList = bindIndex[target] = [];
			}
			
			if(bindList.indexOf(property) != -1) {
				return false;
			}
			
			bindList.push(property);
			target[property] = _value;
			return true;
		}
		
		/**
		 * 
		 */
		public function unbind(target:Object, property:String):Boolean
		{
			var bindList:Array = bindIndex[target];
			if(bindList == null) {
				return false;
			}
			
			var i:int = bindList.indexOf(property);
			if(i == -1) {
				return false;
			}
			
			bindList.splice(i, 1);
			if(bindList.length == 0) {
				delete bindIndex[target];
			}
			return true;
		}
		
		/**
		 * 
		 */
		public function bindListener(listener:Function, useWeakReference:Boolean = true):void
		{
			addEventListener(PropertyEvent.PROPERTY_CHANGE, listener, false, 0, useWeakReference);
			listener( new PropertyEvent(PropertyEvent.PROPERTY_CHANGE, _property, _value, _value) );
		}
		
		/**
		 * 
		 */
		public function unbindListener(listener:Function):void
		{
			removeEventListener(PropertyEvent.PROPERTY_CHANGE, listener);
		}
		
		/**
		 * 
		 */
		public function hasBinds():Boolean
		{
			for(var target:* in bindIndex) {
				return true;
			}
			
			return hasEventListener(PropertyEvent.PROPERTY_CHANGE);
		}
		
		/**
		 * 
		 */
		public function release():void
		{
			unbindPath(0);
		}
		
		public function reset(source:Object, sourcePath:String = null):void
		{
			release();
			
			if(sourcePath != null) {
				_sourcePath = sourcePath.split(".");
				_property = _sourcePath[ _sourcePath.length-1 ];
			}
			
			update(source, 0);
		}
		
		private function getSource(pathIndex:int = 0):Object
		{
			for(var source:* in indicesIndex) {
				if(indicesIndex[source] != pathIndex) {
					continue;
				}
				return source;
			}
			
			return null;
		}
		
		private function update(source:Object, pathIndex:int = 0):void
		{
			if(!updating) {
				updating = true;
				
				var oldValue:Object = _value;
				_value = bindPath(source, pathIndex);		// udpate full path
				
				if(oldValue != _value) {
					
					// update bound targets
					for(var target:* in bindIndex) {
						
						var bindList:Array = bindIndex[target];
						for(var i:int = 0; i < bindList.length; i++) {
							
							var prop:String = bindList[i];
							target[prop] = _value;
						}
					}
					// update bound listeners
					PropertyEvent.dispatchChange(this, _property, oldValue, _value);
				}
				
				updating = false;
			}
		}
		
		private function bindPath(source:Object, pathIndex:int):Object
		{
			unbindPath(pathIndex+1);
			if(_sourcePath.length == 0) {
				return null;
			}
			
			var prop:String;
			var newValue:Object = source;
			for(var i:int = pathIndex; i < _sourcePath.length; i++) {
				
				source = newValue;
				prop = _sourcePath[i];
				
				if( !(prop in source) ) {
					trace("Binding access of undefined property " + prop + " in " + getClassName(source) + ".");
					source = newValue = null;
				}
				if(source == null) {
					break;
				}
				
				if(source is IEventDispatcher) {
					var changeEvent:String = getBindingEvent(source, prop);
					IEventDispatcher(source).addEventListener(changeEvent, onPropertyChange);
				}
				indicesIndex[source] = i;
				newValue = source[prop];
			}
			
			if(explicitValue != null && i == _sourcePath.length) {
				source[prop] = newValue = explicitValue;
				if(!applyOnly) {
					explicitValue = null;
				}
			}
			
			return newValue;
		}
		
		private function unbindPath(pathIndex:int):void
		{
			for(var source:* in indicesIndex) {
				var index:int = indicesIndex[source];
				if(index < pathIndex) {
					continue;
				}
				
				if(source is IEventDispatcher) {
					var changeEvent:String = getBindingEvent(source, _sourcePath[index]);
					IEventDispatcher(source).removeEventListener(changeEvent, onPropertyChange);
				}
				delete indicesIndex[source];
			}
		}
		
		private function onPropertyChange(event:Event):void
		{
			var source:Object = event.target;
			var pathIndex:int = indicesIndex[source];
			var prop:String = _sourcePath[pathIndex];
			if("property" in event && event["property"] != prop) {
				return;
			}
			
			update(source, pathIndex);
		}
		
		
		// ====== STATIC MEMEBERS ====== //
		
		private static var descCache:Dictionary = new Dictionary();
		private static var bindingIndex:Dictionary = new Dictionary(true);
		
		/**
		 * 
		 */
		public static function getBinding(source:Object, sourcePath:String):Binding
		{
			var bindingList:Array = bindingIndex[source];
			if(bindingList == null) {
				bindingList = bindingIndex[source] = [];
			}
			
			var binding:Binding = bindingList[sourcePath];
			if(binding == null) {
				binding = new Binding(source, sourcePath);
				bindingList[sourcePath] = binding;
			}
			
			return binding;
		}
		
		/**
		 * 
		 */
		public static function releaseBinding(binding:Binding):Boolean
		{
			var source:Object = binding.getSource(0);
			var sourcePath:String = binding.sourcePath;
			
			return release(source, sourcePath);
		}
		
		/**
		 * 
		 */
		public static function release(source:Object, sourcePath:String):Boolean
		{
			var bindingList:Array = bindingIndex[source];
			if(bindingList == null) {
				return false;
			}
			
			var binding:Binding = bindingList[sourcePath];
			if(binding == null) {
				return false;
			}
			
			delete bindingList[sourcePath];
			binding.release();
			
			return true;
		}
		
		private static function getBindingEvent(target:Object, property:String):String
		{
			var bindings:Array = describeBindings(target);
			if(bindings[property] == null) {
				bindings[property] = property + PropertyEvent._CHANGE;
			}
			return bindings[property];
		}
		
		private static function describeBindings(value:Object):Array
		{
			if( !(value is Class) ) {
				value = getType(value);
			}
			
			if(descCache[value] == null) {
				var desc:XMLList = Type.describeProperties(value, "Bindable");
				var bindings:Array = descCache[value] = [];
				
				for each(var prop:XML in desc) {
					var property:String = prop.@name;
					var changeEvent:String;
					var bindable:XMLList = prop.metadata.(@name == "Bindable");
					
					if(bindable.arg.(@key == "event").length() != 0)
						changeEvent = bindable.arg.(@key == "event").@value;
					else
						changeEvent = bindable.arg.@value;
					
					if(changeEvent == PropertyEvent.PROPERTY_CHANGE && bindable.arg.(@key == "flight").@value == "true")
						changeEvent = property + PropertyEvent._CHANGE;
					
					bindings[property] = changeEvent;
				}
			}
			
			return descCache[value];	
		}
		
	}
}
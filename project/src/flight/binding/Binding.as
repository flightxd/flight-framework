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
	
	import flight.events.PropertyChangeEvent;
	import flight.utils.Type;
	import flight.utils.getType;
	
	/**
	 * 
	 */
	public class Binding extends EventDispatcher
	{
		public var updateOnly:Boolean = false;
		
		private var indicesIndex:Dictionary = new Dictionary(true);
		private var bindIndex:Dictionary = new Dictionary(true);
		
		private var explicitValue:Object;
		private var updating:Boolean = false;
		private var _value:Object;
		private var _property:String;
		private var _sourcePath:Array;
		
		/**
		 * 
		 */
		public function Binding(source:Object, sourcePath:String)
		{
			_sourcePath = sourcePath.split(".");
			_property = _sourcePath[ _sourcePath.length-1 ];
			
			update(source, 0);
		}
		
		/**
		 * 
		 */
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
		public function addListener(listener:Function):void
		{
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, listener, false, 0, true);
			listener( new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, _property, _value, _value) );
		}
		
		/**
		 * 
		 */
		public function removeListener(listener:Function):void
		{
			removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, listener);
		}
		
		/**
		 * 
		 */
		public function hasBinds():Boolean
		{
			for(var target:* in bindIndex) {
				return true;
			}
			
			return hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE);
		}
		
		/**
		 * 
		 */
		public function release():void
		{
			unbindPath(0);
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
			if(updating) {
				return;
			}
			updating = true;
			
			var newValue:Object = bindPath(source, pathIndex);		// udpate full path
			PropertyChangeEvent.dispatchPropertyChange(this, _property, _value, _value = newValue);
			
			for(var target:* in bindIndex) {
				var bindList:Array = bindIndex[target];
				for(var i:int = 0; i < bindList.length; i++) {
					target[bindList[i]] = newValue;
				}
			}
			
			updating = false;
		}
		
		private function bindPath(source:Object, pathIndex:int):Object
		{
			unbindPath(pathIndex+1);
			
			var prop:String;
			var newValue:Object = source;
			for(var i:int = pathIndex; i < _sourcePath.length; i++) {
				
				source = newValue;
				prop = _sourcePath[i];
				if(source == null || !(prop in source)) {
					newValue = null;
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
				if(!updateOnly) {
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
		public static function bind(target:Object, targetPath:String, source:Object, sourcePath:String, twoWay:Boolean = false):Boolean
		{
			var binding:Binding = Binding.getBinding(source, sourcePath);
			
			var success:Boolean;
			if(twoWay || targetPath.split(".").length > 1) {
				var binding2:Binding = Binding.getBinding(target, targetPath);
				
				success = binding.bind(binding2, "value");
				if(!twoWay) {
					binding2.updateOnly = true;
				} else {
					binding2.bind(binding, "value");
				}
			} else {
				success = binding.bind(target, targetPath);
			}
			return success;
		}
		
		/**
		 * 
		 */
		public static function unbind(target:Object, targetPath:String, source:Object, sourcePath:String):Boolean
		{
			var binding:Binding = Binding.getBinding(source, sourcePath);
			var success:Boolean = binding.unbind(target, targetPath);
			
			if(!success) {
				var binding2:Binding = Binding.getBinding(target, targetPath);
				
				success = binding.unbind(binding2, "value");
				binding2.unbind(binding, "value");
				if( !binding2.hasBinds() ) {
					Binding.releaseBinding(binding2);
				}
			}
			
			if( !binding.hasBinds() ) {
				Binding.releaseBinding(binding);
			}
			return success;
		}
		
		/**
		 * 
		 */
		public static function bindSetter(setter:Function, source:Object, sourcePath:String):void
		{
			var binding:Binding = Binding.getBinding(source, sourcePath);
			binding.addListener(setter);
		}
		
		/**
		 * 
		 */
		public static function unbindSetter(setter:Function, source:Object, sourcePath:String):void
		{
			var binding:Binding = Binding.getBinding(source, sourcePath);
			binding.removeListener(setter);
			if( !binding.hasBinds() ) {
				Binding.releaseBinding(binding);
			}
		}
		
		/**
		 * 
		 */
		public static function getBinding(source:Object, sourcePath:String):Binding
		{
			var bindingList:Array = bindingIndex[source];
			if(bindingList == null) {
				bindingList = bindingIndex[source] = [];
			}
			
			var binding:Binding;
			var i:int = bindingList.indexOf(sourcePath);
			if(i == -1) {
				binding = new Binding(source, sourcePath);
				bindingList.push(binding);
			} else {
				binding = bindingList[i];
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
			
			var i:int = bindingList.indexOf(sourcePath);
			if(i == -1) {
				return false;
			}
			
			var binding:Binding = bindingList.splice(i, 1)[0];
				binding.release();
			
			return true;
		}
		
		private static function getBindingEvent(target:Object, property:String):String
		{
			var bindings:Array = describeBindings(target);
			if(bindings[property] == null) {
				bindings[property] = property + PropertyChangeEvent._CHANGE;
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
					
					if(changeEvent == PropertyChangeEvent.PROPERTY_CHANGE && bindable.arg.(@key == "flight").@value == "true")
						changeEvent = property + PropertyChangeEvent._CHANGE;
					
					bindings[property] = changeEvent;
				}
			}
			
			return descCache[value];	
		}
		
	}
}
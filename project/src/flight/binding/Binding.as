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
		protected var indicesIndex:Dictionary = new Dictionary(true);
		protected var bindIndex:Dictionary = new Dictionary(true);
		
		private var explicitValue:Object;
		private var updating:Boolean = false;
		private var _value:Object;
		private var _property:String;
		private var _sourcePath:Array;
		
		
		public function Binding(source:Object, sourcePath:String)
		{
			_sourcePath = sourcePath.split(".");
			_property = _sourcePath[ _sourcePath.length-1 ];
			
			update(source, 0);
		}
		
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
		
		public function get property():String
		{
			return _property;
		}
		
		public function get sourcePath():String
		{
			return _sourcePath.join(".");
		}
		
		public function bind(target:Object, property:String):void
		{
			var bindList:Array = bindIndex[target];
			if(bindList == null) {
				bindList = bindIndex[target] = [];
			}
			
			if(bindList.indexOf(property) == -1) {
				bindList.push(property);
			}
			target[property] = _value;
		}
		
		public function unbind(target:Object, property:String):void
		{
			var bindList:Array = bindIndex[target];
			if(bindList == null) {
				return;
			}
			
			var i:int = bindList.indexOf(property);
			if(i != -1) {
				bindList.splice(i, 1);
			}
		}
		
		public function addListener(listener:Function):void
		{
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, listener, false, 0, true);
			listener( new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, _property, _value, _value) );
		}
		
		public function removeListener(listener:Function):void
		{
			removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, listener);
		}
		
		public function release():void
		{
			unbindPath(0);
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
				explicitValue = null;
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
		
		private function getSource(pathIndex:int = 0):Object
		{
			for(var source:* in indicesIndex) {
				if(indicesIndex[source] != pathIndex) {
					continue;
				}
				return source;
			}
			
			if(pathIndex == 0)	{	// if the source has been removed from memory
				release();			// TODO: remove from Bind dictionaries, also pair Source/Target bindings
			}
			
			return null;
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
		
		
		
		// TODO: review scope (private) of these static methods
		private static function getBindingEvent(target:Object, property:String):String
		{
			var bindings:Array = describeBindings(target);
			if(bindings[property] == null) {
				bindings[property] = property + PropertyChangeEvent._CHANGE;
			}
			return bindings[property];
		}
		
		private static var bindingsCache:Dictionary = new Dictionary();
		private static function describeBindings(value:Object):Array
		{
			if( !(value is Class) ) {
				value = getType(value);
			}
			
			if(bindingsCache[value] == null) {
				var desc:XMLList = Type.describeProperties(value, "Bindable");
				var bindings:Array = bindingsCache[value] = [];
				
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
			
			return bindingsCache[value];	
		}
	}
}
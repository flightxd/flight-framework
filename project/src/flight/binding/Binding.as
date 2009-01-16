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
//		public var pairedBinding:Binding;
		
		private var updating:Boolean = false;
		private var setterValue:Object;
		private var indices:Dictionary = new Dictionary(true);
		
		private var _value:Object;
		private var _property:String;
		private var _sourcePath:Array;
		
		
		public function get value():Object
		{
			return _value;
		}
		public function set value(value:Object):void
		{
			if(_value == value) {
				return;
			}
			
			_value = value;
			// TODO: update binding
		}
		
		public function get property():String
		{
			return _property;
		}
		
		public function get sourcePath():Array
		{
			return _sourcePath;
		}
		
		public function Binding(source:Object, sourcePath:String, listener:Function = null)
		{
			this._sourcePath = sourcePath.split(".");
			_property = this._sourcePath[this._sourcePath.length-1];
//			bindingIndex[source] = this;
			indices[source] = -1;
			
			update(source, -1);
			if(listener != null)
				addListener(listener);
		}
		
		public function bind(target:Object, targetPath:String):void
		{
		}
		
		public function unbind(target:Object, targetPath:String):void
		{
		}
		
		public function addListener(listener:Function):void
		{
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, listener, false, 0, true);
			listener( new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, _property, value, value) );
		}
		
		public function removeListener(listener:Function):void
		{
			removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, listener);
		}
		
		public function release():void
		{
			unbindPath(-1);
//			delete bindingIndex[getSource];
			
//			if(pairedBinding)
//			{
//				pairedBinding.pairedBinding = null;
//				pairedBinding.release();
//				pairedBinding = null;
//			}
		}
		
		// invoked from another Binding instance
//		public function setter(event:PropertyChangeEvent):void
//		{
//			var target:Object = getSource(sourcePath.length-2);
//			if(target != null)
//				target[property] = event.newValue;
//			else
//				setterValue = event.newValue;
//		}
		
		
		
		
		
		private function update(source:Object, pathIndex:int = 0):void
		{
			if(updating)
				return;
			
			updating = true;
			var newValue:Object;
			if(pathIndex+1 == _sourcePath.length-1)
				newValue = source[_property];	// last bindable object
			else
				newValue = bindPath(source, pathIndex);
			
			PropertyChangeEvent.dispatchPropertyChange(this, _property, value, value = newValue);
			updating = false;
		}
		
		private function bindPath(source:Object, pathIndex:int):Object
		{
			unbindPath(pathIndex+1);
			
			var object:Object = source;
			for(var i:int = pathIndex+1; i < _sourcePath.length; i++)
			{
				var prop:String = _sourcePath[i];
				if(object == null || !(prop in object))
				{
					object = null;
					break;
				}
				
				if(object is IEventDispatcher)
				{
					var changeEvent:String = getBindingEvent(object, prop);
					IEventDispatcher(object).addEventListener(changeEvent, onPropertyChange);
				}
				indices[object] = i-1;
				object = object[prop];
			}
			
			if(setterValue != null && i == _sourcePath.length)
			{
				object = setterValue;	// TODO: set to object!
				setterValue = null;
			}
			
			return object;
		}
		
		private function unbindPath(pathIndex:int):void
		{
			for(var o:* in indices)
			{
				var index:int = indices[o];
				if(index < pathIndex)
					continue;
				
				if(o is IEventDispatcher)
				{
					var changeEvent:String = getBindingEvent(o, _sourcePath[index]);
					IEventDispatcher(o).removeEventListener(changeEvent, onPropertyChange);
				}
				delete indices[o];
			}
		}
		
		private function getSource(pathIndex:int = -1):Object
		{
			for(var o:* in indices)
			{
				if(indices[o] == pathIndex)
					return o;
			}
			if(pathIndex == -1)	// if the source has been removed from memory
				release();		// TODO: remove from Bind dictionaries, also pair Source/Target bindings
			return null;
		}
		
		private function onPropertyChange(event:Event):void
		{
			var source:Object = event.target;
			var pathIndex:int = indices[source];
			var prop:String = _sourcePath[pathIndex+1];
			if("property" in event && event["property"] != prop)
				return;
			
			update(source, pathIndex);
		}
		
		
		
		// TODO: review scope (private) of these static methods
		private static function getBindingEvent(target:Object, property:String):String
		{
			var bindings:Array = describeBindings(target);
			if(bindings[property] == null)
				bindings[property] = property + PropertyChangeEvent._CHANGE;
			return bindings[property];
		}
		
		private static var bindingsCache:Dictionary = new Dictionary();
		private static function describeBindings(value:Object):Array
		{
			if( !(value is Class) )
				value = getType(value);
			
			if(bindingsCache[value] == null)
			{
				var desc:XMLList = Type.describeProperties(value, "Bindable");
				var bindings:Array = bindingsCache[value] = [];
				
				for each(var prop:XML in desc)
				{
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
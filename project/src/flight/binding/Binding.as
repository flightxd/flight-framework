package flight.binding
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import flight.events.PropertyEvent;
	import flight.utils.Type;
	import flight.utils.getClassName;
	import flight.utils.getType;
	
	import mx.events.PropertyChangeEvent;
	
	[ExcludeClass]
	
	/**
	 * Binding will bind two properties together. They can be shallow or deep
	 * and one way or two way.
	 */
	public class Binding
	{
		protected static const SOURCE:String = "source";
		protected static const TARGET:String = "target";
		
		protected var sourceIndices:Dictionary = new Dictionary(true);
		protected var targetIndices:Dictionary = new Dictionary(true);
		
		protected var _sourcePath:Array;
		protected var _targetPath:Array;
		
		protected var _twoWay:Boolean;
		protected var _value:*;
		
		protected var sourceResolved:Boolean;
		protected var targetResolved:Boolean;
		protected var updating:Boolean;
		
		
		/**
		 * 
		 */
		public function Binding(target:Object = null, targetPath:String = null, source:Object = null, sourcePath:String = null, twoWay:Boolean = false)
		{
			if (target && source && sourcePath) {
				reset(target, targetPath, source, sourcePath, twoWay);
			}
		}
		
		/**
		 * Indicates whether this binding has dropped either the source or the
		 * target. If either were dropped out of memory the binding is no longer
		 * valid and shoudl be released appropriatly.
		 */
		public function get isInvalid():Boolean
		{
			var i:Object;
			for (i in sourceIndices) {
				for (i in targetIndices) return false;
			}
			return true;
		}
		
		public function get target():Object
		{
			for (var i:Object in targetIndices) {
				if (targetIndices[i] == 0) return i;
			}
			return null;
		}
		
		public function get source():Object
		{
			for (var i:Object in sourceIndices) {
				if (sourceIndices[i] == 0) return i;
			}
			return null;
		}
		
		public function get targetPath():String
		{
			return _targetPath.join(".");
		}
		
		public function get sourcePath():String
		{
			return _sourcePath.join(".");
		}
		
		public function get twoWay():Boolean
		{
			return _twoWay;
		}
		
		public function get value():*
		{
			return _value;
		}
		
		/**
		 * 
		 */
		public function release():void
		{
			unbindPath(SOURCE, 0);
			unbindPath(TARGET, 0);
			_sourcePath = null;
			_targetPath = null;
			_twoWay = false;
			sourceResolved = false;
			targetResolved = false;
			_value = undefined;
		}
		
		public function reset(target:Object, targetPath:String, source:Object, sourcePath:String, twoWay:Boolean):void
		{
			release();
			_twoWay = twoWay;
			
			_sourcePath = sourcePath.split(".");
			_targetPath = targetPath ? targetPath.split(".") : [];
			
			bindPath(TARGET, target, 0);
			update(SOURCE, source, 0);
		}
		
		protected function update(type:String, item:Object, pathIndex:int = 0):void
		{
			var indices:Dictionary = this[type + "Indices"];
			var path:Array = this["_" + type + "Path"];
			
			var oldValue:* = _value;
			_value = bindPath(type, item, pathIndex);		// udpate full path
			
			if (oldValue === _value) return;
			
			var listener:Function = target as Function;
			if (listener != null) {
				var params:Array = [_value, oldValue, this];
				params.length = listener.length;
				listener.apply(null, params.reverse());
			} else {
				updating = true;
				var otherType:String = (type == SOURCE ? TARGET : SOURCE);
				var resolved:Boolean = this[otherType + "Resolved"];
				if (resolved) {
					var otherPath:Array = this["_" + otherType + "Path"];
					var otherItem:Object = getItem(otherType, otherPath.length - 1); // item + path.length
					if (otherItem) {
						var prop:String = otherPath[otherPath.length - 1];
						setProp(otherItem, prop, oldValue, _value);
					}
				}
				updating = false;
			}
		}
		
		/**
		 * Bind a path up starting from the given index.
		 */
		protected function bindPath(type:String, item:Object, pathIndex:int):*
		{
			var indices:Dictionary = this[type + "Indices"];
			var path:Array = this["_" + type + "Path"];
			var onPropertyChange:Function = this[type + "ChangeHandler"];
			
			unbindPath(type, pathIndex);
			
			var resolved:Boolean;
			var prop:String;
			var len:int = path.length || 1;
			for (pathIndex; pathIndex < len; pathIndex++) {
				
				if (item == null) {
					break;
				}
				
				indices[item] = pathIndex;
				
				if (pathIndex == path.length) break;
				prop = path[pathIndex];
				
				if (_twoWay || type == SOURCE || pathIndex < len-1) {
					if (item is IEventDispatcher) {
						var changeEvents:Array = getBindingEvents(item, prop);
						for each (var changeEvent:String in changeEvents) {
							IEventDispatcher(item).addEventListener(changeEvent, onPropertyChange, false, 100, true);
						}
					} else {
						trace("Warning: Property '" + prop + "' is not bindable in " + getClassName(item) + ".");
					}
				}
				
				try {
					item = getProp(item, prop);
				} catch (e:Error) {
					item = null;
				}
			}
			
			// if we've reached the end of the chain successfully (item + path - 1)
			this[type + "Resolved"] = resolved = Boolean(pathIndex == len || item != null);
			if (!resolved) {
				return null;
			}
			
			return item;
		}
		
		/**
		 * Removes all event listeners from a certain point (index) in the path
		 * on up. A pathIndex of 0 will remove all listeners for the given type.
		 */
		protected function unbindPath(type:String, pathIndex:int):void
		{
			var indices:Dictionary = this[type + "Indices"];
			var path:Array = this["_" + type + "Path"];
			var onPropertyChange:Function = this[type + "ChangeHandler"];
			
			for (var item:* in indices) {
				var index:int = indices[item];
				if (index < pathIndex) {
					continue;
				}
				
				if (item is IEventDispatcher) {
					var changeEvents:Array = getBindingEvents(item, path[index]);
					for each (var changeEvent:String in changeEvents) {
						IEventDispatcher(item).removeEventListener(changeEvent, onPropertyChange);
					}
				}
				delete indices[item];
			}
		}
		
		
		protected function getItem(type:String, pathIndex:int = 0):Object
		{
			var indices:Dictionary = this[type + "Indices"];
			
			for (var item:* in indices) {
				if (indices[item] != pathIndex) {
					continue;
				}
				return item;
			}
			
			return null;
		}
		
		protected function getProp(item:Object, prop:String):*
		{
			if (prop in item && item[prop] is Function) {
				var params:Array = [item];
				params.length = item[prop].length;
				return item[prop].apply(null, params);
			}
			try {
				return item[prop];
			} catch (e:Error){}
			
			return null;
		}
		
		protected function setProp(item:Object, prop:String, oldValue:*, value:*):void
		{
			if (prop in item && item[prop] is Function) {
				var getter:Function = item[prop] as Function;
				var params:Array = [_value, oldValue, item, this];
				params.length = getter.length;
				getter.apply(null, params.reverse());
			}
			try {
				item[prop] = value;
			} catch (e:Error){}
		}
		
		protected function sourceChangeHandler(event:Event):void
		{
			if (updating) return;
			var source:Object = event.target;
			var pathIndex:int = sourceIndices[source];
			var prop:String = _sourcePath[pathIndex];
			if (event is PropertyChangeEvent && PropertyChangeEvent(event).property != prop) {
				return;
			}
			
			update(SOURCE, source[prop], pathIndex + 1);
		}
		
		protected function targetChangeHandler(event:Event):void
		{
			if (updating) return;
			var target:Object = event.target;
			var pathIndex:int = targetIndices[target];
			var prop:String = _targetPath[pathIndex];
			if (event is PropertyChangeEvent && PropertyChangeEvent(event).property != prop) {
				return;
			}
			
			if (_twoWay) {
				update(TARGET, target[prop], pathIndex + 1);
			} else {
				bindPath(TARGET, target[prop], pathIndex + 1);
				if (sourceResolved && targetResolved) {
					target = getItem(TARGET, _targetPath.length - 1);
					prop = _targetPath[_targetPath.length - 1];
					try {
						target[prop] = _value;
					} catch (e:Error) {}
				}
			}
		}
		
		
		
		protected static var descCache:Dictionary = new Dictionary();
		
		protected static function getBindingEvents(target:Object, property:String):Array
		{
			var bindings:Object = describeBindings(target);
			if (bindings[property] == null) {
				bindings[property] = [property + PropertyEvent.CHANGE];
			}
			return bindings[property];
		}
		
		protected static function describeBindings(value:Object):Object
		{
			if ( !(value is Class) ) {
				value = getType(value);
			}
			
			if (descCache[value] == null) {
				var desc:XMLList = Type.describeProperties(value, "Bindable");
				var bindings:Object = descCache[value] = [];
				
				for each (var prop:XML in desc) {
					var property:String = prop.@name;
					var changeEvents:Array = [];
					var bindable:XMLList = prop.metadata.(@name == "Bindable");
					
					for each (var bind:XML in bindable) {
						var changeEvent:String = (bind.arg.(@key == "event").length() != 0) ?
							bind.arg.(@key == "event").@value :
							changeEvent = bind.arg.@value;
						
						changeEvents.push(changeEvent);
					}
					
					bindings[property] = changeEvents;
				}
			}
			
			return descCache[value];
		}
	}
}

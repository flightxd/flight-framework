package flight.observers
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	public class Observe
	{
		private static var targets:Dictionary = new Dictionary(true);
		private static var types:Dictionary = new Dictionary(true);
		
		public static function watch(target:Object, property:String, observerHost:IEventDispatcher, observer:Function):void
		{
			var storage:Dictionary = target is Class ? types : targets;
			var properties:Object = storage[target];
			if (!properties) {
				storage[target] = properties = {};
			}
			
			var observers:Dictionary = properties[property];
			if (!observers) {
				properties[property] = observers = new Dictionary(true);
			}
			
			observers[observer] = true;
			if (observerHost != null) {
				observerHost.addEventListener("_", observer);
			}
		}
		
		public static function unwatch(target:Object, property:String, observer:Function):void
		{
			var storage:Dictionary = target is Class ? types : targets;
			var properties:Object = storage[target];
			if (!properties) return;
			
			var observers:Dictionary = properties[property];
			if (!observers) return;
			
			delete observers[observer];
		}
		
		public static function watchAll(target:Object, observerHost:IEventDispatcher, observer:Function):void
		{
			watch(target, "*", observerHost, observer);
		}
		
		public static function unwatchAll(target:Object, observer:Function):void
		{
			unwatch(target, "*", observer);
		}
		
		public static function unwatchCompletely(target:Object):void
		{
			var storage:Dictionary = target is Class ? types : targets;
			var properties:Object = storage[target];
			if (!properties) return;
			
			for (var property:String in properties) {
				delete properties[property];
			}
		}
		
		public static function notifyChange(target:Object, property:String, oldValue:*, newValue:*):void
		{
			var i:uint;
			var properties:Object = targets[target];
			if (!properties) {
				return;
			}
			
			var observers:Dictionary = properties[property];
			if (observers) {
				notifyObservers(observers, target, property, oldValue, newValue);
			}
			
			observers = properties["*"];
			if (observers) {
				notifyObservers(observers, target, property, oldValue, newValue);
			}
			
			var typeObservers:Array = findTypeObservers(target, property);
			for each (observers in typeObservers) {
				notifyObservers(observers, target, property, oldValue, newValue);
			}
		}
		
		private static function notifyObservers(observers:Dictionary, target:Object, property:String, oldValue:*, newValue:*):void
		{
			for (var i:Object in observers) {
				var observer:Function = i as Function;
				if (observer.length == 0) {
					observer.call();
				} else if (observer.length == 1) {
					observer.call(null, newValue);
				} else if (observer.length == 2) {
					observer.call(null, oldValue, newValue);
				} else if (observer.length == 3) {
					observer.call(null, property, oldValue, newValue);
				} else {
					observer.call(null, target, property, oldValue, newValue);
				}
			}
		}
		
		private static function findTypeObservers(target:Object, property:String):Array
		{
			var observers:Array = [];
			for (var i:Object in types) {
				var type:Class = i as Class;
				if (target is type) {
					var properties:Object = types[type];
					if (property in properties) {
						observers.push(properties[property]);
					}
					if ("*" in properties) {
						observers.push(properties["*"]);
					}
				}
			}
			return observers;
		}
	}
}
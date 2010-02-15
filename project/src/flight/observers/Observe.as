package flight.observers
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	public class Observe
	{
		private static const CHECK:String = "check";
		private static const HOOK:String = "hook";
		private static const OBSERVE:String = "observe";
		private static var targets:Dictionary = new Dictionary(true);
		private static var types:Dictionary = new Dictionary(true);
		
		public static function check(target:Object, property:String, observerHost:IEventDispatcher, observer:Function):void
		{
			addFunction(CHECK, target, property, observerHost, observer);
		}
		
		public static function stopChecking(target:Object, property:String, observer:Function):void
		{
			removeFunction(target, property, observer);
		}
		
		public static function checkAll(target:Object, observerHost:IEventDispatcher, observer:Function):void
		{
			addFunction(CHECK, target, "*", observerHost, observer);
		}
		
		public static function stopCheckingAll(target:Object, observer:Function):void
		{
			removeFunction(target, "*", observer);
		}
		
		public static function hook(target:Object, property:String, observerHost:IEventDispatcher, observer:Function):void
		{
			addFunction(OBSERVE, target, property, observerHost, observer);
		}
		
		public static function stopHooking(target:Object, property:String, observer:Function):void
		{
			removeFunction(target, property, observer);
		}
		
		public static function hookAll(target:Object, observerHost:IEventDispatcher, observer:Function):void
		{
			addFunction(OBSERVE, target, "*", observerHost, observer);
		}
		
		public static function stopHookinAll(target:Object, observer:Function):void
		{
			removeFunction(target, "*", observer);
		}
		
		public static function observe(target:Object, property:String, observerHost:IEventDispatcher, observer:Function):void
		{
			addFunction(OBSERVE, target, property, observerHost, observer);
		}
		
		public static function stopObserving(target:Object, property:String, observer:Function):void
		{
			removeFunction(target, property, observer);
		}
		
		public static function observeAll(target:Object, observerHost:IEventDispatcher, observer:Function):void
		{
			addFunction(OBSERVE, target, "*", observerHost, observer);
		}
		
		public static function stopObservingAll(target:Object, observer:Function):void
		{
			removeFunction(target, "*", observer);
		}
		
		public static function release(target:Object):void
		{
			var storage:Dictionary = target is Class ? types : targets;
			var properties:Object = storage[target];
			if (!properties) return;
			
			for (var property:String in properties) {
				delete properties[property];
			}
		}
		
		public static function canChange(target:Object, property:String, oldValue:*, newValue:*):Boolean
		{
			var check:Boolean = true;
			var properties:Object = targets[target];
			if (!properties) {
				return true;
			}
			
			var checks:Dictionary = properties[property];
			if (checks) {
				check = runFunctions(CHECK, checks, target, property, oldValue, newValue);
				if (!check) return false;
			}
			
			checks = properties["*"];
			if (checks) {
				check = runFunctions(CHECK, checks, target, property, oldValue, newValue);
				if (!check) return false;
			}
			
			var typeObservers:Array = findTypeObservers(target, property);
			for each (checks in typeObservers) {
				check = runFunctions(CHECK, checks, target, property, oldValue, newValue);
				if (!check) return false;
			}
			
			return true;
		}
		
		public static function modifyChange(target:Object, property:String, oldValue:*, newValue:*):*
		{
			var properties:Object = targets[target];
			if (!properties) {
				return;
			}
			
			var hooks:Dictionary = properties[property];
			if (hooks) {
				newValue = runFunctions(HOOK, hooks, target, property, oldValue, newValue);
			}
			
			hooks = properties["*"];
			if (hooks) {
				newValue = runFunctions(HOOK, hooks, target, property, oldValue, newValue);
			}
			
			var typeObservers:Array = findTypeObservers(target, property);
			for each (hooks in typeObservers) {
				newValue = runFunctions(HOOK, hooks, target, property, oldValue, newValue);
			}
		}
		
		public static function notifyChange(target:Object, property:String, oldValue:*, newValue:*):void
		{
			var properties:Object = targets[target];
			if (!properties) {
				return;
			}
			
			var observers:Dictionary = properties[property];
			if (observers) {
				runFunctions(OBSERVE, observers, target, property, oldValue, newValue);
			}
			
			observers = properties["*"];
			if (observers) {
				runFunctions(OBSERVE, observers, target, property, oldValue, newValue);
			}
			
			var typeObservers:Array = findTypeObservers(target, property);
			for each (observers in typeObservers) {
				runFunctions(OBSERVE, observers, target, property, oldValue, newValue);
			}
		}
		
		private static function addFunction(type:String, target:Object, property:String, observerHost:IEventDispatcher, observer:Function):void
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
			
			observers[observer] = type;
			if (observerHost != null) {
				observerHost.addEventListener("_", observer);
			}
		}
		
		private static function removeFunction(target:Object, property:String, observer:Function):void
		{
			var storage:Dictionary = target is Class ? types : targets;
			var properties:Object = storage[target];
			if (!properties) return;
			
			var observers:Dictionary = properties[property];
			if (!observers) return;
			
			delete observers[observer];
		}
		
		private static function runFunctions(type:String, funcs:Dictionary, target:Object, property:String, oldValue:*, newValue:*):*
		{
			var result:*;
			for (var i:Object in funcs) {
				if (funcs[i] != type) continue;
				var func:Function = i as Function;
				if (func.length == 0) {
					result = func.call();
				} else if (func.length == 1) {
					result = func.call(null, newValue);
				} else if (func.length == 2) {
					result = func.call(null, oldValue, newValue);
				} else if (func.length == 3) {
					result = func.call(null, property, oldValue, newValue);
				} else {
					result = func.call(null, target, property, oldValue, newValue);
				}
				if (type == CHECK && result == false) return false;
				if (type == HOOK) newValue = result;
			}
			return newValue;
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
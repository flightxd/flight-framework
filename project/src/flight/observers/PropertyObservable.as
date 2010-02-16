package flight.observers
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	public class PropertyObservable extends EventDispatcher implements IPropertyObservable
	{
		private static const CHECK:String = "check";
		private static const HOOK:String = "hook";
		private static const OBSERVE:String = "observe";
		private var target:IPropertyObservable;
		private var properties:Object = {};
		
		public function PropertyObservable(target:IPropertyObservable = null)
		{
			this.target = target || this;
		}
		
		public function addCheck(property:String, observerHost:IEventDispatcher, observer:Function):void
		{
			addFunction(Observe.CHECK, property, observerHost, observer);
		}
		
		public function removeCheck(property:String, observer:Function):void
		{
			removeFunction(property, observer);
		}
		
		public function addHook(property:String, observerHost:IEventDispatcher, observer:Function):void
		{
			addFunction(Observe.HOOK, property, observerHost, observer);
		}
		
		public function removeHook(property:String, observer:Function):void
		{
			removeFunction(property, observer);
		}
		
		public function addObserver(property:String, observerHost:IEventDispatcher, observer:Function):void
		{
			addFunction(Observe.OBSERVE, property, observerHost, observer);
		}
		
		public function removeObserver(property:String, observer:Function):void
		{
			removeFunction(property, observer);
		}
		
		public function canChange(property:String, oldValue:*, newValue:*):Boolean
		{
			var check:Boolean = true;
			
			var checks:Dictionary = properties[property];
			if (checks) {
				check = runFunctions(Observe.CHECK, checks, property, oldValue, newValue);
				if (!check) return false;
			}
			
			checks = properties["*"];
			if (checks) {
				check = runFunctions(Observe.CHECK, checks, property, oldValue, newValue);
				if (!check) return false;
			}
			
			var typeChecks:Array = Observe.findTypeObservers(target, property);
			for each (checks in typeChecks) {
				check = runFunctions(Observe.CHECK, checks, property, oldValue, newValue);
				if (!check) return false;
			}
			
			return true;
		}
		
		public function modifyChange(property:String, oldValue:*, newValue:*):*
		{
			var hooks:Dictionary = properties[property];
			if (hooks) {
				newValue = runFunctions(Observe.HOOK, hooks, property, oldValue, newValue);
			}
			
			hooks = properties["*"];
			if (hooks) {
				newValue = runFunctions(Observe.HOOK, hooks, property, oldValue, newValue);
			}
			
			var typeHooks:Array = Observe.findTypeObservers(target, property);
			for each (hooks in typeHooks) {
				newValue = runFunctions(Observe.HOOK, hooks, property, oldValue, newValue);
			}
		}
		
		public function notifyChange(property:String, oldValue:*, newValue:*):void
		{
			var observers:Dictionary = properties[property];
			if (observers) {
				runFunctions(Observe.OBSERVE, observers, property, oldValue, newValue);
			}
			
			observers = properties["*"];
			if (observers) {
				runFunctions(Observe.OBSERVE, observers, property, oldValue, newValue);
			}
			
			var typeObservers:Array = Observe.findTypeObservers(target, property);
			for each (observers in typeObservers) {
				runFunctions(Observe.OBSERVE, observers, property, oldValue, newValue);
			}
		}
		
		private function addFunction(type:String, property:String, observerHost:IEventDispatcher, observer:Function):void
		{
			var funcs:Dictionary = properties[property];
			if (!funcs) {
				properties[property] = funcs = new Dictionary(true);
			}
			
			funcs[observer] = type;
			if (observerHost != null) {
				observerHost.addEventListener("_", observer);
			}
		}
		
		private function removeFunction(property:String, observer:Function):void
		{
			var observers:Dictionary = properties[property];
			if (!observers) return;
			
			delete observers[observer];
		}
		
		private function runFunctions(type:String, funcs:Dictionary, property:String, oldValue:*, newValue:*):*
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
				if (type == Observe.CHECK && result == false) return false;
				if (type == Observe.HOOK) newValue = result;
			}
			return newValue;
		}
	}
}
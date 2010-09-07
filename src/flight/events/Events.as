package flight.events
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	public class Events
	{
		private static var universalDispatcher:EventDispatcher = new EventDispatcher();
		
		public static function addListener(dispatcher:Object, type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
		{
			if ( !(dispatcher is IEventDispatcher) ) {
				dispatcher = universalDispatcher;
				type = getId(dispatcher) + ":" + type;		// "change" -> "104:change"
			}
			
			IEventDispatcher(dispatcher).addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public static function removeListener(dispatcher:Object, type:String, listener:Function, useCapture:Boolean=false):void
		{
			if ( !(dispatcher is IEventDispatcher) ) {
				dispatcher = universalDispatcher;
				type = getId(dispatcher) + ":" + type;
			}
			
			IEventDispatcher(dispatcher).removeEventListener(type, listener, useCapture);
		}
		
		public static function dispatch(dispatcher:Object, event:Event):Boolean
		{
			if ( !(dispatcher is IEventDispatcher) ) {
				if ( !(Event is TargetEvent) ) {
					trace("Warning! Non-EventDispatcher's may only dispatch TargetEvents.");
					return false;
				}
				dispatcher = universalDispatcher;
//				type = getId(_target) + ":" + type;
			}
			
			dispatcher = (event.target is IEventDispatcher) ? IEventDispatcher(event.target) : universalDispatcher;
			return dispatcher.dispatchEvent(event);
		}
		
		public static function hasListener(dispatcher:Object, type:String):Boolean
		{
			if ( !(dispatcher is IEventDispatcher) ) {
				dispatcher = universalDispatcher;
				type = getId(dispatcher) + ":" + type;
			}
			
			return IEventDispatcher(dispatcher).hasEventListener(type);
		}
		
		public static function willTrigger(dispatcher:Object, type:String):Boolean
		{
			if ( !(dispatcher is IEventDispatcher) ) {
				dispatcher = universalDispatcher;
				type = getId(dispatcher) + ":" + type;
			}
			
			return IEventDispatcher(dispatcher).willTrigger(type);
		}
		
		
		private static var idIndex:Dictionary = new Dictionary(true);
		private static var idInc:Number = 0;
		
		private static function getId(dispatcher:Object):Number
		{
			if ( !(dispatcher in idIndex)) {
				idIndex[dispatcher] = ++idInc;
			}
			
			return idIndex[dispatcher];
		}
		
	}
}
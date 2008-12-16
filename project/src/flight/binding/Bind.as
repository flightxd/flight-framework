package flight.binding
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	public class Bind
	{
		public function Bind()
		{
		}
		
		public static function addEventListener(dispatcher:IEventDispatcher, type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
		}
		
		public static function removeEventListener(dispatcher:IEventDispatcher, type:String, listener:Function, useCapture:Boolean=false):void
		{
		}
		
		public static function dispatchEvent(dispatcher:IEventDispatcher, event:Event):Boolean
		{
			if(dispatcher == null)
				return false;
			
			var testDispatch:Function = event.bubbles ? dispatcher.willTrigger : dispatcher.hasEventListener;
			if(!testDispatch(event.type))
				return false;
			
			return dispatcher.dispatchEvent(event);
		}
		
		public static function bindProperty(site:Object, prop:String, host:Object, chain:Object, useWeakReference:Boolean = false):void
		{
		}
		
		public static function bindSetter(site:Object, setter:Function, host:Object, chain:Object, useWeakReference:Boolean = false):void
		{
		}
		
		public static function bindTwoWay(endPoint1:Object, prop1:String, endPoint2:Object, prop2:String, useWeakReference:Boolean = false):void
		{
		}
		
		public static function bindEventListener(type:String, site:Object, listener:Function, host:Object, chain:Object, useCapture:Boolean=false):void
		{
		}
		
		// all the removeBind, removeBindings, removeEvent, removeEvents, removeAll, etc..
		
	}
}
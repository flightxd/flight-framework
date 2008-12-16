package flight.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import flight.utils.Type;
	
	public class ValueObject implements IEventDispatcher, IValueObject
	{
		private var eventDispatcher:EventDispatcher;
		
		public function ValueObject()
		{
		}
		
		public function equals(value:Object):Boolean
		{
			return Type.equals(this, value);
		}
		
		public function clone():Object
		{
			return Type.clone(this);
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if(eventDispatcher == null)
				eventDispatcher = new EventDispatcher(this);
			
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if(eventDispatcher != null)
				eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			if(eventDispatcher != null && eventDispatcher.hasEventListener(event.type))
				return eventDispatcher.dispatchEvent(event);
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			if(eventDispatcher != null)
				return eventDispatcher.hasEventListener(type);
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			if(eventDispatcher != null)
				return eventDispatcher.willTrigger(type);
			return false;
		}
	}
}
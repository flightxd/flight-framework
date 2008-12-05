package flight.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	public class ValueObject implements IEventDispatcher, IValueObject
	{
		private var eventDispatcher:EventDispatcher;
		private var registered:Boolean;
		
		public function ValueObject()
		{
		}
		
		public function equals(value:Object):Boolean
		{
			if(this == value)
				return true;
			
			if(!registered)
				registered = registerType(this);
			
			var so1:ByteArray = new ByteArray();
	       	so1.writeObject(this);
	        
			var so2:ByteArray = new ByteArray();
        	so2.writeObject(value);
			
			return Boolean(so1.toString() == so2.toString());
		}
		
		public function clone():Object
		{
			if(!registered)
				registered = registerType(this);
			
			var so:ByteArray = new ByteArray();
	        so.writeObject(this);
	        
	        so.position = 0;
	        return so.readObject() as ValueObject;
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
			if(eventDispatcher != null)
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
		
		private static var registeredTypes:Dictionary = new Dictionary();
		public static function registerType(value:Object):Boolean
		{
			if( !(value is Class) )
				value = getType(value);
			
			if(!registeredTypes[value])		// no need to register a class more than once
				registeredTypes[value] = registerClassAlias(getQualifiedClassName(value).split("::").join("."), value as Class);
			
			return true;
		}
	}
}
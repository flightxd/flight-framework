package flight.binding
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	public class Bind
	{
		public function Bind()
		{
		}
		
		public static function addEventListener(dispatcher:IEventDispatcher, type:String, listener:Function,
												useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
		}
		
		public static function removeEventListener(dispatcher:IEventDispatcher, type:String, listener:Function,
												   useCapture:Boolean=false):void
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
		
		public static function addBinding(end1:Object, path1:String, end2:Object, path2:String,
										  twoWay:Boolean = false, useWeakReference:Boolean = false):void
		{
			
		}
		
		// build chain and listen to property changes along each link
		// any changes trigger chain rebuild and property evaluation
		// listening setter evaluates end+path to update property
		
		public static function bindEventListener(type:String, site:Object, listener:Function,
												 host:Object, chain:Object, useCapture:Boolean=false):void
		{
		}
		
		// all the removeBind, removeBindings, removeEvent, removeEvents, removeAll, etc..
		
	}
}


import flash.events.IEventDispatcher;
import flash.events.Event;

import flight.events.PropertyChangeEvent;
import flight.utils.Type;

class Binding //site prop host chain
{
	public var target:Object;
	public var targetPath:Array;
	
	public var source:Object;
	public var sourcePath:Array;
	
	
	public function Binding(target:Object, targetPath:String, source:Object, sourcePath:String)
	{
		this.target = target;
		this.targetPath = targetPath.split(".");
		this.source = source;
		this.sourcePath = sourcePath.split(".");
		
		update();
	}
	
	public function update():void
	{
		
	}
	
	public function bindPath():void
	{
		var object:Object = source;
		for each(var property:String in sourcePath)
		{
			if( !(property in object) )
				;// .. end it here
			
			if(object is IEventDispatcher)
			{
				
				var desc:XMLList = Type.describeProperties(object).(@name == property);
				var bindable:XMLList = desc.metadata.(@name == "Bindable");
				var changeEvent:String;
				
				if(bindable.length() == 0)
					changeEvent = property + PropertyChangeEvent._CHANGE;
				else if(bindable.arg.(@key == "event").length() != 0)
					changeEvent = bindable.arg.(@key == "event").@value;
				else
					changeEvent = bindable.arg.@value;
				
				if(changeEvent == PropertyChangeEvent.PROPERTY_CHANGE && bindable.arg.(@key == "flight").@value == "true")
					changeEvent = property + PropertyChangeEvent._CHANGE;
				
				IEventDispatcher(object).addEventListener(changeEvent, onPropertyChange);
			}
			
			object = object[property];
		}
	}
	
	public function unbindPath():void
	{
		
	}
	
	private function onPropertyChange(event:Event):void
	{
		
	}
	
}

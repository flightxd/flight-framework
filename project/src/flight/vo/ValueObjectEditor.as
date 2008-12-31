package flight.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.*;
	
	import flight.utils.Type;
	import flight.utils.getType;
	
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	[Bindable("propertyChange")]
	dynamic public class ValueObjectEditor extends Proxy implements IEventDispatcher
	{
		private static var _proxies:Dictionary = new Dictionary(true);
		
		public static function getProxy( value:IValueObject ):ValueObjectEditor
		{
			if(_proxies[value] == null)
				_proxies[value] = new ValueObjectEditor( value );
			return _proxies[value] as ValueObjectEditor;
		}
		
		protected var eventDispatcher:EventDispatcher;
		
		private var _copy:IValueObject;
		private var _source:IValueObject;
		
		public function ValueObjectEditor( value:IValueObject )
		{
			_source = value;
			_copy = _source.clone() as IValueObject;
			
			eventDispatcher = new EventDispatcher(this);
		}
		
		public function revert():void
		{
			merge( this, _source);
		}
						
		public function get source():IValueObject
		{
			return _source;
		}
		
		override flash_proxy function callProperty(methodName:*, ... args):*
		{
			Function(this[methodName]).apply(this, args);
		}
		
		override flash_proxy function hasProperty(name:*):Boolean 
	    {
	    	return name in _copy;
	    }
		
		override flash_proxy function getProperty(name:*):* 
		{
        	return _copy[name];
	    }
	
	    override flash_proxy function setProperty(name:*, value:*):void 
	    {
	        var oldValue:* = _copy[name];
            _copy[name] = value;
            var kind:String = PropertyChangeEventKind.UPDATE;
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, name, oldValue, value));
	    }
	    
	    public static function commit( editor:ValueObjectEditor ):void
		{
			merge ( editor, editor._copy ); 
		}
		
		public static function merge( editor:ValueObjectEditor, data:Object ):void
		{
			var type:Class = getType(data);
			var src:IValueObject = editor.source;
			
			var propList:XMLList = Type.describeProperties( src );
				propList = propList.(child("metadata").(@name == "Transient").length() == 0)

			for each(var prop:XML in propList) {
				
				var name:String = prop.@name;
				if(data[name] !== undefined) {
					editor[name] = data[name];
				}
			}
		}
		
		public function get modified():Boolean
		{
			return !_copy.equals(_source);
		}

		public function hasEventListener(type:String):Boolean
        {
            return eventDispatcher.hasEventListener(type);
        }
       
        public function willTrigger(type:String):Boolean
        {
            return eventDispatcher.willTrigger(type);
        }
       
        public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false):void
        {
            eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
       
        public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
        {
            eventDispatcher.removeEventListener(type, listener, useCapture);
        }
       
        public function dispatchEvent(event:Event):Boolean
        {
            return eventDispatcher.dispatchEvent(event);
        }
        
		/*		
		override flash_proxy function deleteProperty(name:*):Boolean 
		{
	      return delete items[name];
	    }
	
	    override flash_proxy function nextNameIndex(index:int):int 
	    {
	      if (index > items.length)
	        return 0;
	      return index + 1;
	    }
	
	    override flash_proxy function nextName(index:int):String 
	    {
	      return String(index - 1);
	    }
	
	    override flash_proxy function nextValue(index:int):* 
	    {
	      return items[index - 1];
	    }
		*/
	}
}
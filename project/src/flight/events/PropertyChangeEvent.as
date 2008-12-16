package flight.events
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class PropertyChangeEvent extends Event
	{
		public static const _CHANGE:String = "Change";
		public static const PROPERTY_CHANGE:String = "property" + _CHANGE;
		
		public static function dispatchPropertyChange(source:IEventDispatcher, property:Object,
													  oldValue:Object, newValue:Object):void
		{
			if( source.hasEventListener(property + _CHANGE) )
				source.dispatchEvent( new PropertyChangeEvent(property + _CHANGE, property, oldValue, newValue) );
			
			if( source.hasEventListener(PROPERTY_CHANGE) )
				source.dispatchEvent( new PropertyChangeEvent(PROPERTY_CHANGE, property, oldValue, newValue) );
		}
		
		private var _property:Object;
		private var _oldValue:Object;
		private var _newValue:Object;
		
		public function PropertyChangeEvent(type:String, property:Object, oldValue:Object, newValue:Object)
		{
			super(type);
			_property = property;
			_oldValue = oldValue;
			_newValue = newValue;
		}
		
		public function get property():Object
		{
			return _property;
		}
		
		public function get oldValue():Object
		{
			return _oldValue;
		}
		
		public function get newValue():Object
		{
			return _newValue;
		}
		
	}
}
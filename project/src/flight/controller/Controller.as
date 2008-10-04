package flight.controller
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getDefinitionByName;
	
	import flight.binding.utils.BindingUtils;
	import flight.utils.Type;
	import flight.utils.Registry;
	
	import mx.core.IMXMLObject;
	import mx.events.PropertyChangeEvent;
	
	public class Controller extends EventDispatcher implements IMXMLObject
	{
		private var registeredProperties:Object;
		private var _view:IEventDispatcher;
		
		public function Controller()
		{
			registeredProperties = {};
			initController(this);
		}
		
		public function initialized(document:Object, id:String):void
		{
			if(document is IEventDispatcher)
				view = document as IEventDispatcher;
		}
		
		[Bindable(event="propertyChange")]
		public function get view():IEventDispatcher
		{
			return _view;
		}
		public function set view(value:IEventDispatcher):void
		{
			if(_view == value)
				return;
			
			if(_view != null)
				_view.removeEventListener(Event.ADDED_TO_STAGE, updateView);
			var oldValue:IEventDispatcher = _view;
			_view = value;
			if(_view != null)
				_view.addEventListener(Event.ADDED_TO_STAGE, updateView);
			updateView();
			
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "view", oldValue, value));
		}
		
		public function registerProperty(prop:String):Boolean
		{
			if( !(prop in this) )
				return false;
			
			// retrieve the correct property type from the property list
			var type:String = Type.describeProperties(this).(@name == prop)[0].@type;
			if(!type)
				return false;
			
			// store the property and its type, and setting up the watch if view has been defined
			registeredProperties[prop] = getDefinitionByName(type);
			if(view != null)
				Registry.sync(this, prop, registeredProperties[prop], view);
			return true;
		}
		
		public function unregisterProperty(prop:String):Boolean
		{
			if( !(prop in registeredProperties) )
				return false;
			
			delete registeredProperties[prop];
			Registry.desync(this, prop);
			return true;
		}
		
		public function registerEvent(source:Object, type:String, listener:Function):void
		{
			BindingUtils.bindEventListener(type, this, listener, this, source);
		}
		
		public function unregisterEvent(source:String, type:String, listener:Function):void
		{
			BindingUtils.unbindEventListener(type, this, listener, this, source);
		}
		
		
		private function updateView(event:Event = null):void
		{
			for(var i:String in registeredProperties)
			{
				Registry.sync(this, i, registeredProperties[i], view);
			}
		}
		
		private static function initController(controller:Controller):void 
		{
			var type:Class = Type.getType(controller);
			
			var propList:XMLList = Type.describeProperties(controller).(child("metadata").length() > 0);
			propList = propList.(String(metadata.@name).indexOf("Register") != -1);
			for each(var propNode:XML in propList)
			{
				controller.registerProperty(propNode.@name);
			}
			
			var methList:XMLList = Type.describeMethods(controller).(child("metadata").length() > 0);
			methList = methList.(String(metadata.@name).indexOf("Register") != -1);
			for each(var methNode:XML in methList)
			{
				var event:String = methNode.metadata.arg.(@key == "event").@value;
				if(event.length <= 0)
					continue;
				var source:Object = String(methNode.metadata.arg.(@key == "source").@value);
				source = (source.length <= 0) ? "view" : ["view", source];
				controller.registerEvent(source, event, controller[methNode.@name]);
			}
		}
	}
}
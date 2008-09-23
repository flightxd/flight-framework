package flight.config
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	
	import flight.utils.Registry;
	import flight.utils.Type;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.IMXMLObject;
	import mx.events.PropertyChangeEvent;
	
	[DefaultProperty("configSource")]
	dynamic public class Config extends EventDispatcher implements IMXMLObject
	{
		private static const REGISTRY_SCOPE:String = "Config";
		public static function getInstance(id:Object):Config
		{
			return Registry.lookup(id, REGISTRY_SCOPE) as Config;
		}
		
		private var _configId:Object;
		private var _configSource:Array;
		private var _configData:Object;
		private var _configView:DisplayObject;
		
		public function Config(id:Object = null)
		{
			configSource = [];
			configId = id;
		}
		
		public function get configId():Object
		{
			return _configId;
		}
		public function set configId(value:Object):void
		{
			if(_configId == value)
				return;
			
			Registry.unregister(_configId, REGISTRY_SCOPE);
			_configId = value;
			Registry.register(_configId, this, REGISTRY_SCOPE);
		}
		
		[Bindable(event="propertyChange")]
		public function get configData():Object
		{
			return _configData;
		}
		public function set configData(value:Object):void
		{
			if(_configData == value)
				return;
			
			var oldValue:Object = _configData;
			_configData = value;
			update();
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "configData", oldValue, value));
		}
		
		[Bindable(event="propertyChange")]
		public function get configSource():Array
		{
			return _configSource;
		}
		public function set configSource(value:Array):void
		{
			if(_configSource == value)
				return;
			
			var oldValue:Object = _configSource;
			_configSource = value;
			for each(var source:Config in _configSource)
			{
				BindingUtils.bindSetter(update, source, "configData");
			}
			update();
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "configSource", oldValue, value));
		}
		
		[Bindable(event="propertyChange")]
		public function get configView():DisplayObject
		{
			return _configView;
		}
		public function set configView(value:DisplayObject):void
		{
			if(_configView == value)
				return;
			
			var oldValue:Object = _configView;
			_configView = value;
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "configView", oldValue, value));
		}
		
		public function initialized(document:Object, id:String):void
		{
			if(configId == null)
				configId = id;
			
			if(configView != null)
				return;
			if(document is DisplayObject)
				configView = document as DisplayObject;
			else if(document is Config)
				BindingUtils.bindProperty(this, "configView", document, "configView");
		}
		
		private function update(data:Object = null):void
		{
			// "data" isn't used, but the param is included to allow update to act as a bindSetter
			var propList:XMLList = Type.describeProperties(this);
			
			var configSource:Array = this.configSource.concat(this);
			for each(var prop:XML in propList)
			{
				var name:String = prop.@name;
				if(name.indexOf("config") != -1)
					continue;
				for(var i:int = 0; i < configSource.length; i++)
				{
					var source:Config = configSource[i] as Config;
					var value:Object = (name in source) ? source[name] :
								(source.configData != null && name in source.configData) ?
								source.configData[name] : null;
					if(value != null)
					{
						var type:Class = getDefinitionByName(prop.@type) as Class;
						this[name] = (type == Boolean && value == "false") ? false : type(value);
						break;
					}
				}
			}
		}
		
	}
}

package flight.config
{
	import flash.net.SharedObject;
	
	public class SharedObjectConfig extends Config
	{
		private var _sharedObject:SharedObject;
		
		public function SharedObjectConfig(configId:Object = null)
		{
			super(configId);
		}
		
		override public function set configId(value:Object):void
		{
			super.configId = value;
			if(configId == value)
				return;
			
			_sharedObject = SharedObject.getLocal( "config_" + String(configId) );
			configData = sharedObject.data;
		}
		
		public function get sharedObject():SharedObject
		{
			return _sharedObject;
		}
	}
}
package flight.config
{
	import flash.net.SharedObject;
	
	dynamic public class SharedObjectConfig extends Config
	{
		private var _sharedObject:SharedObject;
		
		public function SharedObjectConfig(id:Object = null)
		{
			this.id = id;
		}
		
		override public function set id(value:Object):void
		{
			super.id = value;
			if(id == value)
				return;
			
			_sharedObject = SharedObject.getLocal( "config_" + String(id) );
			configurations = formatSource(sharedObject.data);
		}
		
		public function get sharedObject():SharedObject
		{
			return _sharedObject;
		}
	}
}
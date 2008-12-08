package flight.config
{
	import flash.net.SharedObject;
	
	dynamic public class SharedObjectConfig extends Config
	{
		private var _sharedObject:SharedObject;
		private var _id:Object;
		
		public function SharedObjectConfig(id:Object = null)
		{
			this.id = id;
		}
		
		// TODO: is this necessary? add binding, etc?
		public function set id(value:Object):void
		{
			if(_id == value)
				return;
			
			_id = value;
			
			_sharedObject = SharedObject.getLocal( "config_" + String(_id) );
			configurations = formatSource(sharedObject.data);
		}
		
		override public function initialized(document:Object, id:String):void
		{
			super.initialized(document, id);
			if(id != null)
				this.id = id;
		}
		
		public function get sharedObject():SharedObject
		{
			return _sharedObject;
		}
	}
}
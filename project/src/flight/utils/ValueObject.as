package flight.utils
{
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	dynamic public class ValueObject extends EventDispatcher implements IValueObject
	{
		public function ValueObject()
		{
			Type.registerType(this);
		}
		
		public function equals(value:Object):Boolean
		{
			if(this == value)
				return true;
			
			var so1:ByteArray = new ByteArray();
	       	so1.writeObject(this);
	        
			var so2:ByteArray = new ByteArray();
        	so2.writeObject(value);
			
			return Boolean(so1.toString() == so2.toString());
		}
		
		public function clone():ValueObject
		{
			var so:ByteArray = new ByteArray();
	        so.writeObject(this);
	        
	        so.position = 0;
	        return so.readObject() as ValueObject;
		}
	}
}
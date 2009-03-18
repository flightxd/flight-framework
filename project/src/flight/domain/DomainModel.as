package flight.domain
{
	import flight.utils.Registry;
	import flight.utils.getType;
	import flight.vo.ValueObject;
	
	import mx.core.IMXMLObject;

	public class DomainModel extends ValueObject implements IMXMLObject
	{
		
		/**
		 * Set up this object.
		 */
		protected function initModel():void
		{
		}
		
		/**
		 * Allows DomainModel to be created in MXML in several places but
		 * refer to the same instance.
		 */
		public function initialized(document:Object, id:String):void
		{
			var type:Class = getType(this);
			var instance:Object = Registry.lookup(type);
			if (instance) {
				document[id] = instance
			} else {
				Registry.register(type, this);
				// set up commands or do whatever you might want to do in the
				// constructor but shouldn't since the object might be throw-away
				initModel(); 
			}
		}
	}
}
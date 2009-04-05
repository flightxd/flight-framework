package flight.utils
{
	import flight.events.FlightDispatcher;
	
	import mx.core.IMXMLObject;
	
	public class Singleton extends FlightDispatcher implements IMXMLObject
	{
		public function Singleton()
		{
			var type:Class = getType(this);
			if (Registry.lookup(type) == null) {
				Registry.register(type, this);
				init();
			}
		}
		
		protected function init():void
		{
		}
		
		public function initialized(document:Object, id:String):void
		{
			if (id != null) {
				document[id] = getInstance(this);
			}
		}
		
		
		
		public static function getInstance(classObject:Object, scope:Object = null):Object
		{
			if ( !(classObject is Class) ) {
				classObject = getType(classObject);
			}
			
			var instance:Object = Registry.lookup(classObject, scope);
			if (instance == null) {
				instance = new classObject();
				Registry.register(classObject, instance, scope);
			}
			return instance;
		}
		
		public static function enforceSingleton(instance:Object, scope:Object = null):void
		{
			var classObject:Class = getType(instance);
			
			if (Registry.lookup(classObject, scope) == null) {
				Registry.register(classObject, instance, scope);
			} else {
				throw new Error(getClassName(classObject) + " class cannot be instantiated more than once.");
			}
		}
		
	}
}
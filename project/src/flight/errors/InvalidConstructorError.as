package flight.errors
{
	import flight.utils.Type;
	
	public class InvalidConstructorError extends TypeError
	{
		public static function staticConstructor(classObject:Object):void
		{
			throw(new InvalidConstructorError(classObject));
		}
		
		public function InvalidConstructorError(classObject:Object)
		{
			super("Error #1115: " + Type.getType(classObject) + " is not a constructor.");
		}
	}
}
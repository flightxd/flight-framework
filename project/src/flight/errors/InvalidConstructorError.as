package flight.errors
{
	import flight.utils.getType;
	
	public class InvalidConstructorError extends TypeError
	{
		public static function staticConstructor(classObject:Object):void
		{
			throw(new InvalidConstructorError(classObject));
		}
		
		public function InvalidConstructorError(classObject:Object)
		{
			super("Error #1115: " + getType(classObject) + " is not a constructor.");
		}
	}
}
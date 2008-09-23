package flight.errors
{
	import flash.utils.getQualifiedClassName;
	
	public class InvalidConstructorError extends TypeError
	{
		public function InvalidConstructorError(classObject:Object)
		{
			super("Error #1115: " + getQualifiedClassName(classObject).split("::").pop() + " is not a constructor.");
		}
	}
}
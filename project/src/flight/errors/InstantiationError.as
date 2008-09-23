package flight.errors
{
	import flash.utils.getQualifiedClassName;
	
	public class InstantiationError extends ArgumentError
	{
		public function InstantiationError(classObject:Object)
		{
			super("Error #2012: " + getQualifiedClassName(classObject).split("::").pop() + " class cannot be instantiated.");
		}
	}
}
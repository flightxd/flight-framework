package flight.errors
{
	import flash.utils.getQualifiedClassName;
	
	public class AbstractMethodCallError extends ArgumentError
	{
		public function AbstractMethodCallError(classObject:Object, methodName:String = null)
		{
			methodName = (methodName != null) ? methodName + " " : "";
			super("Illegal call of abstract method " + methodName + "in " + getQualifiedClassName(classObject).split("::").pop() + ".");
		}
	}
}
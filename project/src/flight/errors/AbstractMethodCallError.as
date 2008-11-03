package flight.errors
{
	import flight.utils.getClassName;
	
	public class AbstractMethodCallError extends ArgumentError
	{
		public static function abstractMethodCall(thisReference:Object, callee:Function, methodName:String):void
		{
			if( !(methodName in thisReference) )
				return;
			
			if(thisReference[methodName] == callee)
				throw(new AbstractMethodCallError(thisReference, methodName));
		}
		
		public function AbstractMethodCallError(classObject:Object, methodName:String = null)
		{
			methodName = (methodName != null) ? methodName + " " : "";
			super("Illegal call of abstract method " + methodName + "in " + getClassName(classObject) + ".");
		}
	}
}
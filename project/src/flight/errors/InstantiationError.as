package flight.errors
{
	import flight.utils.getClassName;
	import flight.utils.getType;
	
	public class InstantiationError extends ArgumentError
	{
		public static function abstractInstantiation(thisReference:Object, classObject:Class):void
		{
			if(getType(thisReference) === classObject)
				throw(new InstantiationError(classObject));	
		}
		
		public function InstantiationError(classObject:Object)
		{
			super("Error #2012: " + getClassName(classObject) + " class cannot be instantiated.");
		}
	}
}
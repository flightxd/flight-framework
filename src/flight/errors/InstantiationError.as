/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.errors
{
	import flight.utils.getClassName;
	import flight.utils.getType;
	
	public class InstantiationError extends ArgumentError
	{
		public static function abstractInstantiation(thisReference:Object, classObject:Class):void
		{
			if (getType(thisReference) === classObject) {
				throw(new InstantiationError(classObject));
			}	
		}
		
		public function InstantiationError(classObject:Object)
		{
			super("Error #2012: " + getClassName(classObject) + " class cannot be instantiated.");
		}
	}
}
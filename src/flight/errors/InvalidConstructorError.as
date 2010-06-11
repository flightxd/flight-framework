/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.errors
{
	import flight.utils.getClassName;
	
	public class InvalidConstructorError extends TypeError
	{
		public static function staticConstructor(classObject:Object):void
		{
			throw(new InvalidConstructorError(classObject));
		}
		
		public function InvalidConstructorError(classObject:Object)
		{
			super("Error #1115: " + getClassName(classObject) + " is not a constructor.");
		}
	}
}
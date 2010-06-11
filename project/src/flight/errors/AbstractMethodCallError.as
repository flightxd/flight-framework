/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.errors
{
	import flight.utils.getClassName;
	
	public class AbstractMethodCallError extends ArgumentError
	{
		public static function abstractMethodCall(thisReference:Object, callee:Function, methodName:String):void
		{
			if (thisReference[methodName] == callee) {
				throw(new AbstractMethodCallError(thisReference, methodName));
			}
		}
		
		public function AbstractMethodCallError(classObject:Object, methodName:String = null)
		{
			methodName = (methodName != null) ? methodName + " " : "";
			super("Illegal call of abstract method " + methodName + "in " + getClassName(classObject) + ".");
		}
	}
}
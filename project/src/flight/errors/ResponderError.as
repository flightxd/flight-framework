/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.errors
{
	public class ResponderError extends Error
	{
		public var info:Object;
		
		public function ResponderError(info:Object = null)
		{
			super("Responder status received" + (info is String ? ": " + info : ".") );
			this.info = info;
		}
		
	}
}

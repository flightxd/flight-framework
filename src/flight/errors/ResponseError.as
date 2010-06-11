/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.errors
{
	public class ResponseError extends Error
	{
		public var faultError:Error;
		
		public function ResponseError(faultError:* = "", id:int = 0)
		{
			if (faultError is String) {
				super(faultError, id);
			} else {
				this.faultError = faultError as Error;
			}
		}
		
	}
}
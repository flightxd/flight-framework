/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.net
{
	/**
	 * The ResponseStatus class provides constant values to use for the
	 * <code>IResponse.status</code> property. 
	 */
	public class ResponseStatus
	{
		/**
		 * Specifies that the response is currently in-progress and has not yet
		 * resolved.
		 */
		public static const PROGRESS:String = "progress";
		
		/**
		 * Specifies that the response has resolved successfully.
		 */
		public static const RESULT:String = "result";
		
		/**
		 * Specifies that their was an error during the response.
		 */
		public static const FAULT:String = "fault";
	}
}
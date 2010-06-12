/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.log
{
	/**
	 * These priorities are always available, and a convenience method of the same name is available for each one.
	 * The priorities are not arbitrary. They come from the BSD syslog protocol, which is described in RFC-3164. 
	 * The names and corresponding priority numbers are also compatible with other logging systems, promoting 
	 * interoperability.
	 * 
	 * Priority numbers descend in order of importance. EMERGENCY (0) is the most important priority. DEBUG (7) 
	 * is the least important priority of the built-in priorities. You may define priorities of lower importance 
	 * than DEBUG. When selecting the priority for your log message, be aware of this priority hierarchy and choose 
	 * appropriately.
	 */	
	
	final public class MessageLogPriority
	{
		/**
		 *  Emergency: system is unusable
		 */		
		public static const EMERGENCY:int   = 0;
		
		/**
		 * Alert: action must be taken immediately
		 */
		public static const ALERT:int   	= 1;
		
		/**
		 * Critical: critical conditions
		 */
		public static const CRITICAL:int    = 2;
		
		/**
		 * Error: error conditions
		 */
		public static const ERROR:int     	= 3;
		
		/**
		 * Warning: warning conditions
		 */
		public static const WARNING:int    	= 4;
		
		/**
		 * Notice: normal but significant condition
		 */
		public static const NOTICE:int  	= 5;
		
		/**
		 * Informational: informational messages
		 */
		public static const INFO:int    	= 6;
		
		/**
		 * Debug: debug messages
		 */
		public static const DEBUG:int   	= 7;
	}
}
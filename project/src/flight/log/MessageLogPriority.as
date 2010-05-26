////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2009 Tyler Wright, Robert Taylor, Jacob Wright
//	
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//	
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

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
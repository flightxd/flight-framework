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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.*;
	
	import flight.events.MessageLogEvent;
	
	[Event(name="log", type="flight.events.MessageLogEvent")]

	dynamic public class MessageLog extends Proxy implements IEventDispatcher
	{
		// :: STATIC ACCESSORS :: // 
		private static var logs:Array = new Array();
		
		public static function getMessageLog(id:String = "default"):MessageLog
		{
			if (logs[id] == null) {
				logs[id] = new MessageLog();
			}
			return logs[id];
		}
		
		// :: LOCAL ACCESSORS :: //
		
		public var userDefinedPriorities:Object = new Object();
		public var filters:Object = new Object();
		
		public function MessageLog()
		{
			
		}
		
		// :: Declared Methods :: //
		
		public function emerg(message:String, details:Object=null):void
		{
			dispatchEvent(new MessageLogEvent(MessageLogEvent.LOG, MessageLogPriority.EMERGENCY, message, details));
		}
		
		public function alert(message:String, details:Object=null):void
		{
			dispatchEvent(new MessageLogEvent(MessageLogEvent.LOG, MessageLogPriority.ALERT, message, details));
		}
		
		public function critical(message:String, details:Object=null):void
		{
			dispatchEvent(new MessageLogEvent(MessageLogEvent.LOG, MessageLogPriority.CRITICAL, message, details));
		}
		
		public function error(message:String, details:Object=null):void
		{
			dispatchEvent(new MessageLogEvent(MessageLogEvent.LOG, MessageLogPriority.ERROR, message, details));
		}
		
		public function warn(message:String, details:Object=null):void
		{
			dispatchEvent(new MessageLogEvent(MessageLogEvent.LOG, MessageLogPriority.WARNING, message, details));
		}
		
		public function notice(message:String, details:Object=null):void
		{
			dispatchEvent(new MessageLogEvent(MessageLogEvent.LOG, MessageLogPriority.NOTICE, message, details));
		}
		
		public function info(message:String, details:Object=null):void
		{
			dispatchEvent(new MessageLogEvent(MessageLogEvent.LOG, MessageLogPriority.INFO, message, details));
		}
		
		public function debug(message:String, details:Object=null):void
		{
			dispatchEvent(new MessageLogEvent(MessageLogEvent.LOG, MessageLogPriority.DEBUG, message, details));
		}	
		
		public function addPriority(name:String, level:int):void
		{
			userDefinedPriorities[name] = level;	
		}
		
		public function filterOut(priority:int):void
		{
			filters[priority] = true;
		}
		
		// :: Proxy Implementation :: // 
		
		override flash_proxy function callProperty(methodName:*, ...args):*
		{
			if (userDefinedPriorities[methodName] == null) {
				return false;
			}
			
			dispatchEvent(new MessageLogEvent(MessageLogEvent.LOG, userDefinedPriorities[methodName], args[0], args[1]));
			
			return true;	
		}
		
		flash_proxy function hasOwnProperty(name:String):Boolean
		{
			return userDefinedPriorities[name] != null;
		}
		
		/*
    	override flash_proxy function getProperty(name:*):* 
    	{
    		// ... do nothing ...
    		return null;
    	}

    	override flash_proxy function setProperty(name:*, value:*):void 
    	{
        	// ... do nothing ...
    	}
    	*/
				
		
		// :: EventDispatcher Implementation :: //
		
		private var dispatcher:EventDispatcher = new EventDispatcher();
		

		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			if (filters[MessageLogEvent(event).priority]) {
				return false;
			}
			
			return dispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}
		
	}
}
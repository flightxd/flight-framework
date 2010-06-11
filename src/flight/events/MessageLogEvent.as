/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.events
{
	import flash.events.Event;

	public class MessageLogEvent extends Event
	{
		public static const LOG:String = 'log';
		
		private var _priority:int;
		private var _message:String;
		private var _details:Object;
		
		public function MessageLogEvent(type:String, priority:int, message:String, details:Object=null)
		{
			super(type);
			
			_priority = priority;
			_message = message;
			_details = details;
		}
		
		public function get priority():int
		{
			return _priority;
		}
		
		public function get message():String
		{
			return _message;
		}
		
		public function get details():Object
		{
			return _details;
		}
		
	}
}
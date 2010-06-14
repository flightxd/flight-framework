/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.events
{
	import flash.events.Event;
	
	import flight.net.IResponse;
	import flight.net.Response;
	
	public class ControllerEvent extends Event
	{
		private var _response:IResponse;
		
		public function ControllerEvent(type:String, response:IResponse)
		{
			super(type);
			_response = response;
		}
		
		/**
		 * The IResponse class associated with the ControllerEvent as a read-only.
		 */
		public function get response():IResponse
		{
			return _response;
		}
		
		override public function clone():Event
		{
			return new ControllerEvent(type, response);
		}
	}
}

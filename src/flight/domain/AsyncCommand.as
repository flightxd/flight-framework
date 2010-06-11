/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.domain
{
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import flight.commands.IAsyncCommand;
	import flight.net.IResponse;
	import flight.net.Response;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="cancel", type="flash.events.Event")]
	
	/**
	 * An abstract command class that supports Asynchronous commands through dispatching
	 * the ExecutionComplete event upon completion of the asynchronous action.
	 */
	public class AsyncCommand extends Command implements IAsyncCommand
	{
		private var interval:uint;
		private var _response:IResponse;
		
		[Bindable(event="responseChange")]
		public function get response():IResponse
		{
			if (_response == null) {
				// set response through the setter for appropriate handlers
				response = new Response();
			}
			return _response;
		}
		public function set response(value:IResponse):void
		{
			if (_response == value) {
				return;
			}
			
			if (_response != null) {
				_response.removeResultHandler(onResult);
				_response.removeFaultHandler(onFault);
				
				// link old response to the new response
				if (value != null) {
					_response.progress = value.progress;
					_response.status = value.status;
					value.addResultHandler(_response.complete);
					value.addFaultHandler(_response.cancel);
				}
			}
			
			var oldValue:IResponse = _response;
			_response = value;
			
			if (_response != null) {
				_response.addResultHandler(onResult);
				_response.addFaultHandler(onFault);
			}
			
			propertyChange("response", oldValue, _response);
		}
		
		private function complete():void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function cancel():void
		{
			dispatchEvent(new Event(Event.CANCEL));
		}
		
		private function onResult(data:Object):void
		{
			interval = setTimeout(complete, 1);
		}
		
		private function onFault(error:Error):void
		{
			clearTimeout(interval);
			setTimeout(cancel, 1);
		}
	}
}
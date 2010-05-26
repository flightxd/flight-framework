////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2009 Tyler Wright, Robert Taylor, Jacob Wright
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

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
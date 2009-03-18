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

package flight.domain
{
	import flash.events.Event;
	
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
		private var _response:IResponse;
		
		public function get response():IResponse
		{
			if(_response == null) {
				response = new Response();
			}
			return _response;
		}
		public function set response(value:IResponse):void
		{
			var r:Response = _response as Response;
			var v:Response = value as Response;
			
			if(r != null) {
				r.removeEventListener(Event.COMPLETE, onComplete);
				r.removeEventListener(Event.CANCEL, onCancel);
				if (v != null) {
					v.merge(r);
				}
			}
			_response = value;
			if(v != null) {
				v.addEventListener(Event.COMPLETE, onComplete);
				v.addEventListener(Event.CANCEL, onCancel);
			}
		}
		
		private function onComplete(event:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onCancel(event:Event):void
		{
			dispatchEvent(new Event(Event.CANCEL));
		}
	}
}
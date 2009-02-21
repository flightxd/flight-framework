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

package flight.net
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.Responder;
	
	import flight.errors.ResponseError;
	
	public class Response implements IResponse
	{
		protected var eventInfo:Array = [];
		protected var resultHandlers:Array = [];
		protected var faultHandlers:Array = [];
		
		public function Response(dispatcher:IEventDispatcher = null, completeEvent:String = Event.COMPLETE,
																	 cancelEvent:String = Event.CANCEL)
		{
			if (dispatcher != null) {
				addCompleteEvent(dispatcher, completeEvent);
				addCancelEvent(dispatcher, cancelEvent);
			}
		}
		
		
		/**
		 * Adds a handler function to handle the successful results of the
		 * response. The function should accept the data as the first parameter.
		 * If the handler's purpose is to format the data, the handler function
		 * must return the newly formatted data, if not, the return type must be
		 * void. Formatted data will be used in subsequent result handlers. The
		 * first result handler recieves the IEventDispatcher and returns the
		 * results. Other formatters may turn string data into XML or JSON text
		 * into an object.
		 * 
		 * @param The handler function
		 * @param Additional parameters to pass to this handler upon execution.
		 * @return A reference to this instance for method chaining.
		 */
		public function addResultHandler(handler:Function, ... params):IResponse
		{
			params.unshift(handler);
			resultHandlers.push(params);
			return this;
		}
		
		
		/**
		 * Adds a handler function to handle any errors or faults of  the
		 * response. The function should accept an ErrorEvent as the first
		 * parameter.
		 * 
		 * @param The handler function
		 * @param Additional parameters to pass to this handler upon execution.
		 * @return A reference to this instance for method chaining.
		 */
		public function addFaultHandler(handler:Function, ... params):IResponse
		{
			params.unshift(handler);
			faultHandlers.push(params);
			return this;
		}
		
		public function addCompleteEvent(eventDispatcher:IEventDispatcher, eventType:String, resultProperty:String = "target"):void
		{
			eventInfo.push( [eventDispatcher, eventType, resultProperty] );
			eventDispatcher.addEventListener(eventType, onComplete);
		}
		
		public function addCancelEvent(eventDispatcher:IEventDispatcher, eventType:String, faultProperty:String = "text"):void
		{
			eventInfo.push( [eventDispatcher, eventType, faultProperty] );
			eventDispatcher.addEventListener(eventType, onCancel);
		}
		
		public function complete(result:Object):void
		{
			try {
				for each(var params:Array in resultHandlers) {
					var handler:Function = params[0];
					params[0] = result;
					var data:* = handler.apply(null, params);
					if (data !== undefined) { // i.e. return type was not void
						result = data;
					}
				}
			} catch(e:ResponseError) {
				cancel(e);
			}
			
			release();
		}
		
		public function cancel(error:Error):void
		{
			for each(var params:Array in faultHandlers) {
				var handler:Function = params[0];
				params[0] = error;
				var data:* = handler.apply(null, params) as Error;
				if (data !== undefined) { // i.e. return type was not void
					error = data;
				}
			}
			
			release();
		}
		
		
		public function createResponder():Responder
		{
			return new Responder(onComplete, onCancel);
		}
		
		
		protected function release():void
		{
			var eventDispatcher:IEventDispatcher;
			var eventType:String;
			var i:int;
			
			for(i = 0; i < eventInfo.length; i++) {
				eventDispatcher = eventInfo[i][0];
				eventType = eventInfo[i][1];
				eventDispatcher.removeEventListener(eventType, onComplete);
			}
		}
		
		private function onComplete(event:Event):void
		{
			var info:Array = getEventInfo(event);
			if(info != null) {
				complete(event[info[2]]);
			} else {
				complete(event.target);
			}
		}
		
		private function onCancel(event:Event):void
		{
			var info:Array = getEventInfo(event);
			var error:Object;
			if(info != null) {
				error = event[info[2]];
				if( !(error is Error) ) {
					error = new Error(event[info[2]]);
				}
				cancel(error as Error);
			} else {
				cancel( new Error("Exception thrown on event type " + event.type) );
			}
		}
		
		private function getEventInfo(match:Event):Array
		{
			for each(var info:Array in eventInfo) {
				if(info[0] == match.target && info[1] == match.type) {
					return info;
				}
			}
			return null;
		}
	}
}
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
		protected var events:Array = [];
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
		 * @return A reference to this instance for method chaining.
		 */
		public function addResultHandler(handler:Function):IResponse
		{
			resultHandlers.push(handler);
			return this;
		}
		
		
		/**
		 * Adds a handler function to handle any errors or faults of  the
		 * response. The function should accept an ErrorEvent as the first
		 * parameter.
		 * 
		 * @param The handler function
		 * @return A reference to this instance for method chaining.
		 */
		public function addFaultHandler(handler:Function):IResponse
		{
			faultHandlers.push(handler);
			return this;
		}
		
		public function addResultEvent(eventDispatcher:IEventDispatcher, eventType:String):IResponse
		{
			events.push(arguments);
			eventDispatcher.addEventListener(eventType, onResult);
			return this;
		}
		
		public function addCompleteEvent(eventDispatcher:IEventDispatcher, eventType:String):IResponse
		{
			events.push(arguments);
			eventDispatcher.addEventListener(eventType, onComplete);
			return this;
		}
		
		public function addCancelEvent(eventDispatcher:IEventDispatcher, eventType:String):IResponse
		{
			events.push(arguments);
			eventDispatcher.addEventListener(eventType, onCancel);
			return this;
		}
		
		public function complete(result:Object):void
		{
			releaseEvents();
			try {
				for each (var handler:Function in resultHandlers) {
					var data:* = handler(result);
					if (data !== undefined) { // i.e. return type was not void
						result = data;
					}
				}
			} catch(e:ResponseError) {
				cancel(e);
			}
		}
		
		public function cancel(error:Error):void
		{
			releaseEvents();
			for each (var handler:Function in faultHandlers) {
				var data:* = handler(error) as Error;
				if (data !== undefined) { // i.e. return type was not void
					error = data;
				}
			}
		}
		
		
		public function createResponder():Responder
		{
			return new Responder(onComplete, onCancel);
		}
		
		
		protected function releaseEvents():void
		{
			var eventDispatcher:IEventDispatcher;
			var eventType:String;
			var i:int;
			
			for(i = 0; i < events.length; i++) {
				eventDispatcher = events[i][0];
				eventType = events[i][1];
				eventDispatcher.removeEventListener(eventType, onComplete);
			}
		}
		
		protected function onResult(event:Event):void
		{
			complete(event);
		}
		
		protected function onComplete(event:Event):void
		{
			complete(event.target);
		}
		
		protected function onCancel(event:Event):void
		{
			cancel(convertEventToError(event));
		}
		
		protected function convertEventToError(event:Event):Error
		{
			if ("error" in event) {
				return event["error"];
			} else if("text" in event) {
				return new Error(event["text"]);
			} else {
				return new Error("Exception thrown on event type " + event.type);
			}
		}
	}
}
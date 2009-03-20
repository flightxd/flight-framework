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
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.Responder;
	
	import flight.errors.ResponseError;
	import flight.events.FlightDispatcher;
	import flight.events.PropertyEvent;
	import flight.utils.IMerging;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="cancel", type="flash.events.Event")]
	
	public class Response extends FlightDispatcher implements IResponse, IMerging
	{
		public static const PROGRESS:String = "progress";
		public static const RESULT:String = "result";
		public static const FAULT:String = "fault";
		
		protected var result:Object;
		protected var fault:Error;
		
		protected var resultHandlers:Array = [];
		protected var faultHandlers:Array = [];
		
		private var completeEvents:Array;
		private var progressEvents:Array;
		private var cancelEvents:Array;
		
		private var _status:String = PROGRESS;
		private var _progress:Number = 0;
		
		
		public function Response(target:IEventDispatcher = null, completeEvent:String = Event.COMPLETE,
																 cancelEvent:String = Event.CANCEL)
		{
			if (target != null) {
				addCompleteEvent(target, completeEvent);
				addCancelEvent(target, cancelEvent);
			}
		}
		
		[Bindable(event="propertyChange", flight="true")]
		public function get status():String
		{
			return _status;
		}
		
		[Bindable(event="propertyChange", flight="true")]
		public function get progress():Number
		{
			return _progress;
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
		public function addResultHandler(handler:Function, ... resultParams):IResponse
		{
			resultParams.unshift(handler);
			resultHandlers.push(resultParams);
			if(status == RESULT) {
				complete(result);
			}
			return this;
		}
		
		/**
		 * Removes a handler function which has been previously added.
		 * 
		 * @param The handler function
		 * @return A reference to this instance for method chaining.
		 */
		public function removeResultHandler(handler:Function):IResponse
		{
			var length:uint = resultHandlers.length;
			for (var i:uint = 0; i < length; i++) {
				if (resultHandlers[i][0] == handler) {
					resultHandlers.splice(i--, 1);
				}
			}
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
		public function addFaultHandler(handler:Function, ... faultParams):IResponse
		{
			faultParams.unshift(handler);
			faultHandlers.push(faultParams);
			if(status == FAULT) {
				cancel(fault);
			}
			return this;
		}
		
		/**
		 * Removes a handler function which has been previously added.
		 * 
		 * @param The handler function
		 * @return A reference to this instance for method chaining.
		 */
		public function removeFaultHandler(handler:Function):IResponse
		{
			var length:uint = faultHandlers.length;
			for (var i:uint = 0; i < length; i++) {
				if (faultHandlers[i][0] == handler) {
					faultHandlers.splice(i--, 1);
				}
			}
			return this;
		}
		
		public function addCompleteEvent(target:IEventDispatcher, eventType:String, resultProperty:String = "target"):void
		{
			if(completeEvents == null) {
				completeEvents = [];
			}
			completeEvents.push( [target, eventType, resultProperty] );
			target.addEventListener(eventType, onComplete);
		}
		
		public function addProgressEvent(target:IEventDispatcher, eventType:String,
										 progressProperty:String = "bytesLoaded", totalProperty:String = "bytesTotal"):void
		{
			if(progressEvents == null) {
				progressEvents = [];
			}
			progressEvents.push( [target, eventType, progressProperty, totalProperty] );
			target.addEventListener(eventType, onProgress);
		}
		
		public function addCancelEvent(target:IEventDispatcher, eventType:String, faultProperty:String = "text"):void
		{
			if(cancelEvents == null) {
				cancelEvents = [];
			}
			cancelEvents.push( [target, eventType, faultProperty] );
			target.addEventListener(eventType, onCancel);
		}
		
		public function complete(data:Object):IResponse
		{
			result = data;
			
			var oldValues:Array = [_status, _progress];
			_status = RESULT;
			_progress = 1;
			PropertyEvent.dispatchChangeList(this, ["status", "progress"], oldValues);
			
			try {
				for each(var params:Array in resultHandlers) {
					var handler:Function = params[0];
					params[0] = result;
					var formatted:* = handler.apply(null, params);
					if (formatted !== undefined) { // i.e. return type was not void
						result = formatted;
					}
				}
				
				dispatchEvent(new Event(Event.COMPLETE));
				release();
			} catch(e:ResponseError) {
				cancel(e);
			}
			
			return this;
		}
		
		public function cancel(error:Error):IResponse
		{
			fault = error;
			
			var oldValues:Array = [_status, _progress];
			_status = FAULT;
			_progress = 1;
			PropertyEvent.dispatchChangeList(this, ["status", "progress"], oldValues);
			
			for each(var params:Array in faultHandlers) {
				var handler:Function = params[0];
				params[0] = fault;
				var formatted:* = handler.apply(null, params);
				if (formatted !== undefined) { // i.e. return type was not void
					fault = formatted;
				}
			}
			
			dispatchEvent(new Event(Event.CANCEL));
			release();
			return this;
		}
		
		public function merge(source:Object):Boolean
		{
			if(source is Response) {
				
				resultHandlers = resultHandlers.concat(source.resultHandlers);
				faultHandlers = faultHandlers.concat(source.resultHandlers);
				
				if(status == RESULT) {
					complete(result);
				} else if(status == FAULT) {
					cancel(fault);
				}
				return true;
			}
			
			return false;
		}
		
		public function createResponder():Responder
		{
			return new Responder(onComplete, onCancel);
		}
		
		
		protected function release():void
		{
			var target:IEventDispatcher;
			var eventType:String;
			var args:Array;
			
			resultHandlers = [];
			faultHandlers = [];
			
			for each(args in completeEvents) {
				target = args[0];
				eventType = args[1];
				target.removeEventListener(eventType, onComplete);
			}
			
			for each(args in progressEvents) {
				target = args[0];
				eventType = args[1];
				target.removeEventListener(eventType, onProgress);
			}
			
			for each(args in cancelEvents) {
				target = args[0];
				eventType = args[1];
				target.removeEventListener(eventType, onCancel);
			}
			
			dispatcher = null;
		}
		
		private function onComplete(event:Event):void
		{
			var info:Array = getEventInfo(event, completeEvents);
			var prop:String = info[2];
			if(prop in event) {
				complete(event[prop]);
			} else {
				complete(event.target);
			}
		}
		
		private function onProgress(event:Event):void
		{
			var oldValue:Object = _progress;
			var info:Array = getEventInfo(event, progressEvents);
			var prop:String = info[2];
			if(prop in event) {
				_progress = parseFloat(event[prop]);
				prop = info[3];
				if(prop in event) {
					_progress /= parseFloat(event[prop]);
				}
			} else {
				_progress += .1 * (1 - _progress);
			}
			PropertyEvent.dispatchChange(this, "progress", oldValue, _progress);
		}
		
		private function onCancel(event:Event):void
		{
			var info:Array = getEventInfo(event, cancelEvents);
			var prop:String = info[2];
			var error:Object;
			if(prop in event) {
				error = event[prop];
				if( !(error is Error) ) {
					error = new Error(event[prop]);
				}
				cancel(error as Error);
			} else {
				cancel( new Error("Exception thrown on event type " + event.type) );
			}
		}
		
		private function getEventInfo(match:Event, eventsList:Array):Array
		{
			for each(var args:Array in eventsList) {
				if(args[0] == match.target && args[1] == match.type) {
					return args;
				}
			}
			return null;
		}
		
	}
}
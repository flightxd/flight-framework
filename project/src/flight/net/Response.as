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
	import flight.events.PropertyEvent;
	import flight.utils.IMerging;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="cancel", type="flash.events.Event")]
	
	public class Response implements IEventDispatcher, IResponse, IMerging
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
		
		private var _response:IEventDispatcher;
		private var _status:String = PROGRESS;
		private var _progress:Number = 0;
		
		
		public function Response(dispatcher:IEventDispatcher = null, completeEvent:String = Event.COMPLETE,
																	 cancelEvent:String = Event.CANCEL)
		{
			if (dispatcher != null) {
				addCompleteEvent(dispatcher, completeEvent);
				addCancelEvent(dispatcher, cancelEvent);
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
		
		public function addCompleteEvent(eventDispatcher:IEventDispatcher, eventType:String, resultProperty:String = "target"):void
		{
			if(completeEvents == null) {
				completeEvents = [];
			}
			completeEvents.push( [eventDispatcher, eventType, resultProperty] );
			eventDispatcher.addEventListener(eventType, onComplete);
		}
		
		public function addProgressEvent(eventDispatcher:IEventDispatcher, eventType:String,
										 progressProperty:String = "bytesLoaded", totalProperty:String = "bytesTotal"):void
		{
			if(progressEvents == null) {
				progressEvents = [];
			}
			progressEvents.push( [eventDispatcher, eventType, progressProperty, totalProperty] );
			eventDispatcher.addEventListener(eventType, onProgress);
		}
		
		public function addCancelEvent(eventDispatcher:IEventDispatcher, eventType:String, faultProperty:String = "text"):void
		{
			if(cancelEvents == null) {
				cancelEvents = [];
			}
			cancelEvents.push( [eventDispatcher, eventType, faultProperty] );
			eventDispatcher.addEventListener(eventType, onCancel);
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
			var eventDispatcher:IEventDispatcher;
			var eventType:String;
			var args:Array;
			
			resultHandlers = [];
			faultHandlers = [];
			
			for each(args in completeEvents) {
				eventDispatcher = args[0];
				eventType = args[1];
				eventDispatcher.removeEventListener(eventType, onComplete);
			}
			
			for each(args in progressEvents) {
				eventDispatcher = args[0];
				eventType = args[1];
				eventDispatcher.removeEventListener(eventType, onProgress);
			}
			
			for each(args in cancelEvents) {
				eventDispatcher = args[0];
				eventType = args[1];
				eventDispatcher.removeEventListener(eventType, onCancel);
			}
			
			_response = null;
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
		
		
		
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if(_response == null) {
				_response = new EventDispatcher(this);
			}
			_response.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if(_response != null) {
				_response.removeEventListener(type, listener, useCapture);
			}
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			if(_response != null && _response.hasEventListener(event.type)) {
				return _response.dispatchEvent(event);
			}
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			if(_response != null) {
				return _response.hasEventListener(type);
			}
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			if(_response != null) {
				return _response.willTrigger(type);
			}
			return false;
		}
	}
}
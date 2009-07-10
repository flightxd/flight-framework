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

package flight.net
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.Responder;
	
	import flight.errors.ResponseError;
	import flight.events.FlightDispatcher;
	import flight.progress.IProgress;
	import flight.progress.Progress;
	
	/**
	 * An Response object represents a response to some action, replacing a
	 * function's regular return value in order to support asynchronous actions.
	 * By adding callback handlers an object can receive the action's result
	 * when the response is complete.
	 * 
	 * <p>Response supports both asynchronous and synchronous actions. When
	 * handlers are added <em>after</em> the response has completed (which is
	 * the case for synchronous actions) it is immediately invoked. The effect
	 * is the same as if the handler were added before response completion.</p>
	 */
	public class Response extends FlightDispatcher implements IResponse
	{
		/**
		 * The stored result of the response upon completion and subsequent
		 * formatting.
		 */
		protected var result:Object;
		
		/**
		 * The stored error of the response upon cancelation.
		 */
		protected var fault:Error;
		
		/**
		 * List of result handlers. 
		 */
		protected var resultHandlers:Array = [];
		protected var faultHandlers:Array = [];
		
		// lists of event listeners
		private var completeEvents:Array;
		private var cancelEvents:Array;
		
		private var _status:String = ResponseStatus.PROGRESS;
		private var _progress:IProgress;
		
		/**
		 * Creates a new Response object. Response objects should be created as
		 * far along the action path (as deep in the stack) as possible to take
		 * full advantage of the common API.
		 * 
		 * @param	result			Either data or error to immediately complete
		 * 							or cancel the response.
		 */
		public function Response(result:* = undefined)
		{
			if (result is Error) {
				cancel(result as Error);
			} else if (result !== undefined) {
				complete(result);
			}
		}
		
		/**
		 * Indication of whether the response is in progress, has been completed
		 * or has faulted. Valid values of status are 'progress', 'result' and
		 * 'fault' respectfully.
		 * 
		 * @see		flight.net.ResponseStatus
		 */
		public function get status():String
		{
			return _status;
		}
		
		/**
		 * The progress of the response completion. Valuable when measuring
		 * asynchronous progression.
		 * 
		 * @see		flight.progress.IProgress
		 */
		public function get progress():IProgress
		{
			// lazy instantiation to conserve memory
			if (_progress == null) {
				progress = new Progress();
			}
			return _progress;
		}
		public function set progress(value:IProgress):void
		{
			if (_progress == value) {
				return;
			}
			
			var oldValue:Object = _progress;
			_progress = value;
			if (_progress != null && _status != ResponseStatus.PROGRESS) {
				_progress.position = _progress.length;
			}
			propertyChange("progress", oldValue, _progress);
		}
		
		/**
		 * Adds a callback handler to be invoked with the successful results of
		 * the response. Result handlers receive data and have the opportunity
		 * to format the data for subsequent handlers. They can also trigger the
		 * response's fault if the data is invalid by throwing a ResponseError.
		 * 
		 * <p>The method signature should describe a data object as the first
		 * parameter. Additional parameters may be defined and provided when
		 * adding the result handler.</p>
		 * 
		 * <p>To pass on formatted data the handler must return the new value in
		 * its method signature, otherwise the return type should be
		 * <code>void</code>.</p>
		 * 
		 * <p>
		 * <pre>
		 * 	import flight.errors.ResponseError;
		 * 	
		 * 	// example of a formatting handler - also showing a possible fault
		 * 	private function onResult(data:Object):Object
		 * 	{
		 * 		var amf:ByteArray = data as ByteArray;
		 * 		try {
		 * 			data = amf.readObject();
		 * 		} catch (error:Error) {
		 * 			// ejects out of the result handling phase and into fault handling
		 * 			throw new ResponseError("Invalid AMF response: " + amf.toString());
		 * 		}
		 * 		return data;
		 * 	}
		 * </pre>
		 * </p>
		 * 
		 * @param	handler			The handler method to be invoked upon
		 * 							response success.
		 * @param	resultParams	Additional parameters to be passed to the
		 * 							handler upon execution.
		 * 
		 * @return					A reference to this instance of IResponse,
		 * 							useful for method chaining.
		 * 
		 * @see		flight.errors.ResponseError
		 */
		public function addResultHandler(handler:Function, ... resultParams):IResponse
		{
			resultParams.unshift(handler);
			resultHandlers.push(resultParams);
			if (status == ResponseStatus.RESULT) {
				runHandlers();
			}
			return this;
		}
		
		/**
		 * Removes a result callback handler that has been previously added. If
		 * the same handler has been added more than once, removeResultHandler()
		 * will only remove the latest instance of the handler.
		 * 
		 * @param	handler			The handler method to remove.
		 * 
		 * @return					A reference to this instance of IResponse,
		 * 							useful for method chaining.
		 */
		public function removeResultHandler(handler:Function):IResponse
		{
			var i:uint = resultHandlers.length;
			while (i--) {
				if (resultHandlers[i][0] == handler) {
					resultHandlers.splice(i, 1);
					return this;
				}
			}
			return this;
		}
		
		/**
		 * Adds a callback handler to be invoked with the failure of the
		 * response, receiving an error.
		 * 
		 * <p>The method signature should describe an error type as the first
		 * parameter. Additional parameters may be defined and provided when
		 * adding the fault handler.</p>
		 * 
		 * <p>
		 * <pre>
		 * 	import mx.controls.Alert;
		 * 	
		 * 	// example of a fault handler
		 * 	private function onFault(error:Error):void
		 * 	{
		 * 		Alert.show(error.message, "Error");
		 * 	}
		 * </pre>
		 * </p>
		 * 
		 * @param	handler			The handler method to be invoked upon
		 * 							response failure.
		 * @param	resultParams	Additional parameters to be passed to the
		 * 							handler upon execution.
		 * 
		 * @return					A reference to this instance of IResponse,
		 * 							useful for method chaining.
		 * 
		 * @see		flight.errors.ResponseError
		 */
		public function addFaultHandler(handler:Function, ... faultParams):IResponse
		{
			faultParams.unshift(handler);
			faultHandlers.push(faultParams);
			if (status == ResponseStatus.FAULT) {
				runHandlers();
			}
			return this;
		}
		
		/**
		 * Removes a fault callback handler that has been previously added. If
		 * the same handler has been added more than once, removeFaultHandler()
		 * will only remove the latest instance of the handler.
		 * 
		 * @param	handler			The handler method to remove.
		 * 
		 * @return					A reference to this instance of IResponse,
		 * 							useful for method chaining.
		 */
		public function removeFaultHandler(handler:Function):IResponse
		{
			var i:uint = faultHandlers.length;
			while (i--) {
				if (faultHandlers[i][0] == handler) {
					faultHandlers.splice(i, 1);
					return this;
				}
			}
			return this;
		}
		
		/**
		 * Adds Response as an event listener to the target event, resulting in
		 * a response completion once the event is triggered. A convenient
		 * method for tying the response into an asynchronous event flow.
		 * 
		 * <p>Example using the Flash Player's URLLoader:
		 * <pre>
		 * var urlLoader:URLLoader = new URLLoader();
		 * var response:Response = new Response();
		 * response.addCompleteEvent(urlLoader, Event.COMPLETE);
		 * </pre>
		 * </p>
		 * 
		 * @param	target			The event dispatcher object that Response
		 * 							will listen to.
		 * @param	eventType		Event type dispatched by the target.
		 * @param	resultProperty	A property on the event object that will be
		 * 							used as the data for result handlers.
		 * 
		 * @return					A reference to this instance of Response,
		 * 							useful for method chaining.
		 */
		public function addCompleteEvent(target:IEventDispatcher, eventType:String, resultProperty:String = "target"):Response
		{
			if (completeEvents == null) {
				completeEvents = [];
			}
			completeEvents.push( [target, eventType, resultProperty] );
			target.addEventListener(eventType, onComplete);
			return this;
		}
		
		/**
		 * Adds Response as an event listener to the target event, resulting in
		 * a response cancelation once the event is triggered. A convenient
		 * method for tying the response into an asynchronous event flow.
		 * 
		 * <p>Example using the Flash Player's URLLoader:
		 * <pre>
		 * var urlLoader:URLLoader = new URLLoader();
		 * var response:Response = new Response();
		 * response.addCompleteEvent(urlLoader, Event.COMPLETE);
		 * response.addCancelEvent(urlLoader, SecurityErrorEvent.SECURITY_ERROR);
		 * response.addCancelEvent(urlLoader, IOErrorEvent.IO_ERROR);
		 * </pre>
		 * </p>
		 * 
		 * @param	target			The event dispatcher object that Response
		 * 							will listen to.
		 * @param	eventType		Event type dispatched by the target.
		 * @param	resultProperty	A property on the event object that will be
		 * 							used as the data for result handlers.
		 * 
		 * @return					A reference to this instance of Response,
		 * 							useful for method chaining.
		 */
		public function addCancelEvent(target:IEventDispatcher, eventType:String, faultProperty:String = "text"):Response
		{
			if (cancelEvents == null) {
				cancelEvents = [];
			}
			cancelEvents.push( [target, eventType, faultProperty] );
			target.addEventListener(eventType, onCancel);
			return this;
		}
		
		/**
		 * Completes the response with the specified data, triggering the result
		 * cycle.
		 * 
		 * @param	data			The resulting data.
		 */
		public function complete(data:Object):void
		{
			result = data;
			
			var oldValue:Object = _status;
			_status = ResponseStatus.RESULT;
			if (_progress != null) {
				_progress.position = _progress.length;
			}
			propertyChange("status", oldValue, _status);
			
			release();
			runHandlers();
		}
		
		/**
		 * Cancels the response with an error, triggering the fault cycle.
		 * 
		 * @param	error			The faulting error.
		 */
		public function cancel(error:Error):void
		{
			fault = error;
			
			var oldValue:Object = _status;
			_status = ResponseStatus.FAULT;
			if (_progress != null) {
				_progress.position = _progress.length;
			}
			propertyChange("status", oldValue, _status);
			
			release();
			runHandlers();
		}
		
		/**
		 * Convenient construction of Flash Player's Responder specific to this
		 * Response.
		 * 
		 * @return					A Responder object wrapping Response's
		 * 							complete and cancel methods.
		 */
		public function createResponder():Responder
		{
			return new Responder(complete, cancel);
		}
		
		/**
		 * Runs the appropriate result or fault cycle, invoking each handler and
		 * tracking data formatting.
		 */
		protected function runHandlers():void
		{
			if (_status == ResponseStatus.PROGRESS) {
				return;
			}
			
			var handlers:Array = _status == ResponseStatus.RESULT ? resultHandlers : faultHandlers;
			try {
				while (handlers.length > 0) {
					// stored parameters of the add-handler methods
					var params:Array = handlers.shift();
					var handler:Function = params[0];
					// reuse the parameters by swapping the function with the data
					params[0] = this[_status];
					var formatted:* = handler.apply(null, params);
					// if the return type was not void then replace 'result' or 'fault'
					if (formatted !== undefined) {
						this[_status] = formatted;
					}
				}
				
			} catch (error:ResponseError) {
				cancel(error);
			}
		}
		
		/**
		 * Releases complete and cancel event handlers once the response has
		 * been resolved.
		 */
		protected function release():void
		{
			var target:IEventDispatcher;
			var eventType:String;
			var args:Array;
			
			for each (args in completeEvents) {
				target = args[0];
				eventType = args[1];
				target.removeEventListener(eventType, onComplete);
			}
			
			for each (args in cancelEvents) {
				target = args[0];
				eventType = args[1];
				target.removeEventListener(eventType, onCancel);
			}
		}
		
		/**
		 * Catches complete events and retrieves the appropriate data.
		 */
		private function onComplete(event:Event):void
		{
			var info:Array = getEventInfo(event, completeEvents);
			var prop:String = info[2];
			if (prop in event) {
				complete(event[prop]);
			} else {
				complete(event.target);
			}
		}
		
		/**
		 * Catches cancel events and retrieves the appropriate error.
		 */
		private function onCancel(event:Event):void
		{
			var info:Array = getEventInfo(event, cancelEvents);
			var prop:String = info[2];
			var error:Object;
			if (prop in event) {
				error = event[prop];
				if ( !(error is Error) ) {
					error = new Error(error);
				}
				cancel(error as Error);
			} else {
				cancel( new Error("Exception thrown on event type " + event.type) );
			}
		}
		
		/**
		 * Retrieves the appropriate info for the complete or cancel event.
		 */
		private function getEventInfo(match:Event, eventsList:Array):Array
		{
			for each (var args:Array in eventsList) {
				if (args[0] == match.target && args[1] == match.type) {
					return args;
				}
			}
			return null;
		}
		
	}
}
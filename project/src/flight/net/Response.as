package flight.net
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.Responder;
	import flash.utils.getDefinitionByName;
	
	import flight.utils.getClassName;
	
	public class Response implements IResponse
	{
		protected var completeEvents:Array = [];
		protected var cancelEvents:Array = [];
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
		
		public function addCompleteEvent(eventDispatcher:IEventDispatcher, eventType:String):void
		{
			completeEvents.push(arguments);
			eventDispatcher.addEventListener(eventType, onComplete);
		}
		
		public function addCancelEvent(eventDispatcher:IEventDispatcher, eventType:String):void
		{
			cancelEvents.push(arguments);
			eventDispatcher.addEventListener(eventType, onCancel);
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
			} catch (e:Error) {
				cancel(e);
			}
		}
		
		public function cancel(error:Error):void
		{
			releaseEvents();
			for each (var handler:Function in faultHandlers) {
				var data:Error = handler(error) as Error;
				if (data != null) { // i.e. return type was not void
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
			
			for(i = 0; i < completeEvents.length; i++) {
				eventDispatcher = completeEvents[i][0];
				eventType = completeEvents[i][1];
				eventDispatcher.removeEventListener(eventType, onComplete);
			}
			for(i = 0; i < cancelEvents.length; i++) {
				eventDispatcher = cancelEvents[i][0];
				eventType = cancelEvents[i][1];
				eventDispatcher.removeEventListener(eventType, onCancel);
			}
		}
		
		protected function onComplete(event:Event):void
		{
			complete(event.target);
		}
		
		protected function onCancel(event:ErrorEvent):void
		{
			cancel(convertEventToError(event));
		}
		
		protected function convertEventToError(event:ErrorEvent):Error
		{
			if ("error" in event) {
				return event["error"];
			}
			
			var errorName:String = getClassName(event).replace(/Event$/, '');
			var errorType:Object;
			if ( (errorType = getDefinitionByName(errorName)) || (errorType = getDefinitionByName("flash.errors." + errorName)) ) {
				return new errorType(event.text);
			}
			
			return new Error(event.text);
		}
	}
}
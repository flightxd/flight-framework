package flight.net
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.Responder;
	import flash.utils.describeType;
	
	public class Response implements IResponse
	{
		protected var dispatcher:IEventDispatcher;
		protected var resultEvent:String;
		protected var faultEvents:Array;
		protected var resultHandlers:Array = [];
		protected var faultHandlers:Array = [];
		
		public function Response(dispatcher:IEventDispatcher = null, resultEvent:String = "complete", faultEvents:Array = null)
		{
			if (dispatcher != null) {
				setDispatcher(dispatcher, resultEvent, faultEvents);
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
		
		
		public function setDispatcher(dispatcher:IEventDispatcher, resultEvent:String = "complete", faultEvents:Array = null):IResponse
		{
			this.dispatcher = dispatcher;
			
			this.resultEvent = resultEvent;
			this.faultEvents = faultEvents;
			
			dispatcher.addEventListener(resultEvent, onComplete);
			
			if (faultEvents) {
				for each (var faultEvent:String in faultEvents) {
					dispatcher.addEventListener(faultEvent, onFault);
				}
			}
			
			return this;
		}
		
		
		public function createResponder():Responder
		{
			return new Responder(complete, cancel);
		}
		
		
		public function complete(result:Object):void
		{
			removeEvents();
			for each (var handler:Function in resultHandlers) {
				var data:* = handler(data);
				if (data !== undefined) { // i.e. return type was not void
					result = data;
				}
			}
		}
		
		
		public function cancel(fault:Object):void
		{
			removeEvents();
			for each (var handler:Function in faultHandlers) {
				handler(fault);
			}
		}
		
		
		protected function onComplete(event:Event):void
		{
			complete(event.target);
		}
		
		protected function onFault(event:ErrorEvent):void
		{
			cancel(event);
		}
		
		protected function removeEvents():void
		{
			if (dispatcher != null) {
				dispatcher.removeEventListener(resultEvent, onComplete);
				
				if (faultEvents) {
					for each (var faultEvent:String in faultEvents) {
						dispatcher.removeEventListener(faultEvent, onFault);
					}
				}
			}
		}
		
	}
}
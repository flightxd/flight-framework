package flight.net
{
	public interface IResponse
	{
		
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
		function addResultHandler(handler:Function):IResponse;
		
		/**
		 * Adds a handler function to handle any errors or faults of  the
		 * response. The function should accept an ErrorEvent as the first
		 * parameter.
		 * 
		 * @param The handler function
		 * @return A reference to this instance for method chaining.
		 */
		function addFaultHandler(handler:Function):IResponse;
		
	}
}
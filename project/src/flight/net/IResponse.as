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
	import flash.events.IEventDispatcher;
	
	import flight.utils.IMerging;
	
	public interface IResponse
	{
		/**
		 * Indication of whether the response is in progress, has been completed
		 * or has thrown an error. Valid values of status are 'progress', 'result'
		 * and 'fault' respectfully.
		 */
		function get status():String;
		
		/**
		 * The percent completion of the asynchronous response. The progress range
		 * is from zero to one, one being 100% completed. Responses are often zero
		 * until complete when no progress measurement is available.
		 */
		function get progress():Number;
		
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
		function addResultHandler(handler:Function, ... resultParams):IResponse;
		
		/**
		 * Removes a handler function which has been previously added.
		 * 
		 * @param The handler function
		 * @return A reference to this instance for method chaining.
		 */
		function removeResultHandler(handler:Function):IResponse;
		
		/**
		 * Adds a handler function to handle any errors or faults of  the
		 * response. The function should accept an ErrorEvent as the first
		 * parameter.
		 * 
		 * @param The handler function
		 * @param Additional parameters to pass to this handler upon execution.
		 * @return A reference to this instance for method chaining.
		 */
		function addFaultHandler(handler:Function, ... faultParams):IResponse;
		
		/**
		 * Removes a handler function which has been previously added.
		 * 
		 * @param The handler function
		 * @return A reference to this instance for method chaining.
		 */
		function removeFaultHandler(handler:Function):IResponse;
		
		/**
		 * Triggers the result cycle.
		 * 
		 * @param The resulting data.
		 * @return A reference to this instance for method chaining.
		 */
		function complete(data:Object):IResponse;
		
		/**
		 * Triggers the fault cycle.
		 * 
		 * @param The faulting error.
		 * @return A reference to this instance for method chaining.
		 */
		function cancel(error:Error):IResponse;
		
	}
}
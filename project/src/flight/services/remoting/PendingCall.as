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

package flight.services.remoting
{
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import flight.vo.ValueObject;
	
	[Event(name="result", type="flight.services.remoting.ResultEvent")]
	[Event(name="fault", type="flight.services.remoting.FaultEvent")]
		
	public final class PendingCall extends ValueObject
	{		
		internal var connector:NetConnection;
		internal var request:String;
		internal var parameters:Array;

		private var responder:Responder;
		private var concatParams:Array;
		
		public function PendingCall( connection:NetConnection, call:String, params:Array )
		{			
			responder = new Responder ( result, status );
			
			connector = connection;
			request = call;
			parameters = params;	
		}
		
		public function execute ():void 
		{
			concatParams = new Array( request, responder );
			
			connector.call.apply ( connector, concatParams.concat(parameters) );	
		}
		
		private function result ( event:Object ):void 
		{	
			dispatchEvent ( new ResultEvent ( ResultEvent.RESULT, event ) );	
		}
		
		private function status ( event:Object ):void 
		{
			dispatchEvent ( new FaultEvent ( FaultEvent.FAULT, event ) );	
		}

	}
}
package flight.services.remoting
{
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import flight.utils.ValueObject;
	
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
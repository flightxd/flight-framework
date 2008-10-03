/*
 * Based on NetConnection wrapper by Thibault Imbert (bytearray.org)
 */

package flight.services.remoting
{
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	public dynamic class RemotingService extends Proxy implements IEventDispatcher
	{	
		private var _connection:NetConnection;
		private var _dispatcher:EventDispatcher;
		private var _gateway:String;
		private var _enableLimiter:Boolean;
		private var _call:String;
		private var _service:String;
		private var _args:Array;
		private var _rpc:PendingCall;	
		private var _calls:Array;
		
		public function RemotingService ( gateway:String="", service:String="", enableLimiter:Boolean=true, encoding:int=3 )
		{
			_calls = new Array();
			
			_connection = new NetConnection();
			_dispatcher = new EventDispatcher();
			
			_connection.objectEncoding = encoding;
			_connection.client = this;
			_service = service;
			
			_enableLimiter = enableLimiter;
			
			_connection.addEventListener( NetStatusEvent.NET_STATUS, handleEvent );
			_connection.addEventListener( IOErrorEvent.IO_ERROR, handleEvent );
			_connection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, handleEvent );
			_connection.addEventListener( AsyncErrorEvent.ASYNC_ERROR, handleEvent );
			
			if (gateway)
				gatewayURL = gateway;	
		}
		
		/**
		 * This methods lets authenticate a user to the remote service
		 * @param remoteUserName The userName to use
		 * @param remotePassword The password to use
		 * 
		 */		
		public function setRemoteCredentials ( remoteUserName:String, remotePassword:String ):void 
		{
			
			_connection.addHeader( "Credentials", false, { userid : remoteUserName, password : remotePassword } );
			
		}
		
		/**
		 * 
		 * @param service The remote service to use (including full package and name)
		 * 
		 */		
		public function set service ( service:String ):void 
		{
			
			_service = service;
			
		}
		
		/**
		 * 
		 * @return The remote service (including full package and name)
		 * 
		 */		
		public function get service ():String 
		{
			
			return _service;
			
		}
		
		/**
		 * 
		 * @param url The new _gateway URL to use
		 * 
		 */		
		public function set gatewayURL ( value:String ):void 
		{
			
			_connection.connect(_gateway = value);
			
		}
		
		/**
		 * 
		 * @return The _gateway URL
		 * 
		 */		
		public function get gatewayURL ( ):String
		{
			
			return _gateway;
			
		}
	
		/**
		 * 
		 * @return 
		 * 
		 */				
		public function get enableLimiter ( ):Boolean
		{
			
			return _enableLimiter;
			
		}
 
		public function set enableLimiter ( value:Boolean ):void 
		{
			
			_enableLimiter = value;
			
		}

 
        /**
         * 
         * @return 
         * 
         */ 		
        public function toString ( ):String       
        {	
        	return "[RemotingService " + service + " ]";	
        }
		
		
		private function handleEvent ( event:Event ):void
		{
			
			_dispatcher.dispatchEvent ( event );
			
		}
		
		// :: Proxy Implementation :: //
		
		override flash_proxy function callProperty ( methodName:*, ...parameters:* ):*
		{
			
			_call = _service + "." + methodName;
			
			_rpc = new PendingCall ( _connection, _call, parameters);
			
			if(_enableLimiter)
			{
			
				// Same call has already been made, that is currently in process
				var inService:PendingCall = getInService(_rpc);
				
				if(inService)
					return inService;			
			
			}
			
			_calls.push(_rpc);
			
			_rpc.addEventListener(ResultEvent.RESULT, resultHandler, false, 0);
			_rpc.addEventListener(FaultEvent.FAULT, faultHandler, false, 0);
			
			_rpc.execute();
			
			return _rpc;
			
		}
		
		private function resultHandler(event:ResultEvent):void
		{
			removeInService(event.target as PendingCall);
		}
		
		private function faultHandler(event:FaultEvent):void
		{
			removeInService(event.target as PendingCall);
		}
		
		private function getInService(_rpc:PendingCall):PendingCall
		{
			var inService:PendingCall;
			
			for each(inService in _calls)
			{
				if(_rpc.equals(inService))
					return inService;
			}
			
			return null;
		}
		
		private function removeInService(_rpc:PendingCall):Boolean
		{
			var e:String;
			
			for(e in _calls)
			{
				if(_rpc == _calls[e])
				{
					_calls.splice(int(e), 1);
					return true;
				}
			}
			
			return false;
		}
		
		// :: Event Dispatcher Implementation :: // 

		public function addEventListener( type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false ):void
		{
			_dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}

		public function dispatchEvent( event:Event ):Boolean
		{
			return _dispatcher.dispatchEvent( event );
		}

		public function hasEventListener( type:String ):Boolean
		{
			return _dispatcher.hasEventListener( type );
		}

		public function removeEventListener( type:String, listener:Function, useCapture:Boolean=false ):void
		{
			_dispatcher.removeEventListener( type, listener, useCapture );
		}

		public function willTrigger( type:String ):Boolean
		{
			return _dispatcher.willTrigger( type );
		}
		
	}
	
}

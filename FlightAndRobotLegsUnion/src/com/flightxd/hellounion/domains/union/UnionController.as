package com.flightxd.hellounion.domains.union
{
	import com.flightxd.hellounion.domains.union.commands.Connect;
	import com.flightxd.hellounion.domains.union.commands.SendMessage;
	import com.flightxd.hellounion.events.ChatEvent;
	import com.flightxd.hellounion.services.UnionServices;
	
	import flash.display.DisplayObject;
	
	import flight.domain.DomainController;
	import flight.injection.IInjectorSubject;
	import flight.list.ArrayList;
	import flight.net.IResponse;

	/**
	 * @author John Lindquist
	 */
	public class UnionController extends DomainController implements IInjectorSubject
	{
		public static const CONNECT:String = "CONNECT";

		public static const SEND_MESSAGE:String = "SEND_MESSAGE";

		[Bindable]
		public var clients:Array;

		[Bindable]
		public var connectionStatus:String = "not connected";

		[Bindable]
		public var isConnected:Boolean = false;
		
		[Bindable]
		public var messages:ArrayList = new ArrayList();
		
		[Inject]
		public var services:UnionServices;
		
		public function UnionController(context:DisplayObject = null)
		{
			super(context);
		}
		
		public function injected():void
		{
			services.addEventListener(ChatEvent.RECEIVE_MESSAGE, onMessageReceived);
			services.addEventListener(ChatEvent.UPDATE_CLIENT_ATTRIBUTE, onClientUpdate);
		}
		
		
		public function connect():IResponse
		{
			return execute(CONNECT);
		}

		public function sendMessage(message:String):IResponse
		{
			return execute(SEND_MESSAGE, { message: message });
		}
		
		protected function onMessageReceived(event:ChatEvent):void
		{
			var message:String;
			var clientID:String = event.clientID;
			var messageText:String = event.messageText;
			message = "Guest" + clientID + ": " + messageText;
			messages.addItem(message);
		}
		
		protected function onClientUpdate(event:ChatEvent):void
		{
			clients = event.clients;
		}
		
		override protected function init():void
		{
			addCommand(CONNECT, Connect);
			addCommand(SEND_MESSAGE, SendMessage);
		}
	}
}
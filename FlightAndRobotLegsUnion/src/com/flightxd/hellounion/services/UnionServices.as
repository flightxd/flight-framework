package com.flightxd.hellounion.services
{
	import com.flightxd.hellounion.config.UnionConfig;
	import com.flightxd.hellounion.events.ChatEvent;
	
	import flash.display.DisplayObject;
	
	import flight.net.IResponse;
	import flight.net.Response;
	import flight.services.Service;
	
	import net.user1.logger.LogEvent;
	import net.user1.logger.Logger;
	import net.user1.reactor.ConnectionManagerEvent;
	import net.user1.reactor.IClient;
	import net.user1.reactor.Reactor;
	import net.user1.reactor.ReactorEvent;
	import net.user1.reactor.Room;
	import net.user1.reactor.RoomEvent;

	/**
	 * @author John Lindquist
	 */
	public class UnionServices extends Service
	{
		public static const CHAT_MESSAGE:String = "CHAT_MESSAGE";

		public function UnionServices(context:DisplayObject = null)
		{
			super(context);
			logger = reactor.getLog();
			logger.addEventListener(LogEvent.UPDATE, logger_logHandler);
		}

		[Inject]
		public var config:UnionConfig;

		private var logger:Logger;

		private var reactor:Reactor = new Reactor();

		private var room:Room;

		public function connect():IResponse
		{
			var connectResponse:Response = new Response();
			connectResponse.addCompleteEvent(reactor, ReactorEvent.READY);
			connectResponse.addCancelEvent(reactor.getConnectionManager(), ConnectionManagerEvent.CONNECT_FAILURE);
			reactor.connect(config.unionServer, config.unionPort);
			return connectResponse;
		}

		public function getUserName():IResponse
		{
			var getUserNameResponse:Response = new Response();
			return getUserNameResponse;
		}

		public function join():IResponse
		{
			var joinResponse:Response = new Response();
			room = reactor.getRoomManager().createRoom(config.chatRoom);
			room.addMessageListener(CHAT_MESSAGE, chatMessageListener);
			room.addEventListener(RoomEvent.SYNCHRONIZE, synchronizeRoomListener);
			room.addEventListener(RoomEvent.ADD_CLIENT, addClientListener);
			room.addEventListener(RoomEvent.REMOVE_CLIENT, removeClientListener);
			room.addEventListener(RoomEvent.UPDATE_CLIENT_ATTRIBUTE, updateClientAttributeListener);
			joinResponse.addCompleteEvent(room, RoomEvent.JOIN);
			room.join();
			return joinResponse;
		}

		public function sendMessage(message:String):void
		{
			room.sendMessage(CHAT_MESSAGE, true, null, message);
		}

		public function updateUserList():void
		{
			var clients:Array = room.getClients();
			var chatEvent:ChatEvent = new ChatEvent(ChatEvent.UPDATE_CLIENT_ATTRIBUTE);
			chatEvent.clients = clients;
			dispatchEvent(chatEvent);
		}

		protected function addClientListener(event:RoomEvent):void
		{
			dispatchEvent(event);
		}

		protected function chatMessageListener(fromClient:IClient, messageText:String):void
		{
			var chatEvent:ChatEvent = new ChatEvent(ChatEvent.RECEIVE_MESSAGE);
			chatEvent.clientID = fromClient.getClientID();
			chatEvent.messageText = messageText;
			dispatchEvent(chatEvent);
		}

		protected function logger_logHandler(event:LogEvent):void
		{
			dispatchEvent(event);
		}

		protected function removeClientListener(event:RoomEvent):void
		{
			dispatchEvent(event);
			updateUserList();
		}

		protected function synchronizeRoomListener(event:RoomEvent):void
		{
			updateUserList();
		}

		protected function updateClientAttributeListener(event:RoomEvent):void
		{
			updateUserList();
		}
	}
}
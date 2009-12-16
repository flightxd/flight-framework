package com.flightxd.hellounion.domains.union.commands
{
	import com.flightxd.hellounion.view.ChatViewMediator;
	import flight.domain.Command;
	import net.user1.reactor.IClient;
	import net.user1.reactor.RoomEvent;

	/**
	 * @author John Lindquist
	 */
	public class RemoveClient extends Command
	{

		[Inject]
		public var event:RoomEvent;

		[Inject]
		public var mediator:ChatViewMediator;

		override public function execute():void
		{
			var user:String = getUserName(event.getClient());
			var leftMessage:String = " has left the room";
			var message:String = user + leftMessage;
			mediator.updateReceivedMessages(message);
		}

		protected function getUserName(client:IClient):String
		{
			var username:String = client.getAttribute("username");
			if (username == null)
			{
				return "Guest" + client.getClientID();
			}
			else
			{
				return username;
			}
		}
	}
}
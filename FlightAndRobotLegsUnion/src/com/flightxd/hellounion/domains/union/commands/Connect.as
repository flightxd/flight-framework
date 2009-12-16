package com.flightxd.hellounion.domains.union.commands
{
	import com.flightxd.hellounion.domains.union.UnionController;
	import com.flightxd.hellounion.services.UnionServices;
	import flight.domain.AsyncCommand;
	import flight.net.IResponse;
	import net.user1.reactor.Reactor;
	import net.user1.reactor.Room;

	/**
	 * @author John Lindquist
	 */
	public class Connect extends AsyncCommand
	{

		[Inject]
		public var controller:UnionController;

		[Inject]
		public var services:UnionServices;

		override public function execute():void
		{
			var connectResponse:IResponse = services.connect();
			response = connectResponse;
			response.addResultHandler(connectResult);
			response.addFaultHandler(faultHandler);
			//execute after the chain is done
			response.addResultHandler(connectedAndJoined);
		}

		private function connectResult(reactor:Reactor):IResponse
		{
			controller.isConnected = true;
			var joinResponse:IResponse = services.join();
			response = joinResponse;
			response.addResultHandler(joinResult);
			return response;
		}

		private function connectedAndJoined(data:*):void
		{
			//I magically go back to the Mediator if needed!
		}

		private function faultHandler(data:*):void
		{
			//connection fail logic
		}

		private function joinResult(room:Room):void
		{
			//join reult logic
		}
	}
}
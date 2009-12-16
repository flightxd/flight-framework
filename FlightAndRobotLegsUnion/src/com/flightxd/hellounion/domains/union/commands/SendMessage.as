package com.flightxd.hellounion.domains.union.commands
{
	import com.flightxd.hellounion.domains.union.UnionController;
	import com.flightxd.hellounion.services.UnionServices;
	import flight.domain.Command;

	/**
	 * @author John Lindquist
	 */
	public class SendMessage extends Command
	{

		[Inject]
		public var controller:UnionController;

		public var message:String;

		[Inject]
		public var services:UnionServices;

		override public function execute():void
		{
			services.sendMessage(message);
		}
	}
}
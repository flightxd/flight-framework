package com.flightxd.hellounion.events
{
	import flash.events.Event;

	/**
	 * @author John Lindquist
	 */
	public class ChatEvent extends Event
	{
		public static const RECEIVE_MESSAGE:String = "RECEIVE_MESSAGE";

		public static const UPDATE_CLIENT_ATTRIBUTE:String = "UPDATE_CLIENT_ATTRIBUTE";

		public function ChatEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}

		public var clientID:String;

		public var clients:Array;

		public var messageText:String;
	}
}
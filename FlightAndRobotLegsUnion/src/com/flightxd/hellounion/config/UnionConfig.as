package com.flightxd.hellounion.config
{
	import flash.display.DisplayObject;
	
	import flight.config.Config;

	/**
	 * @author John Lindquist
	 */
	public class UnionConfig extends Config
	{
		public var chatRoom:String = "chatRoom";

		public var unionPort:Number = 9100;

		public var unionServer:String = "tryunion.com";
		
		public function UnionConfig(context:DisplayObject = null)
		{
			super(context);
		}
	}
}
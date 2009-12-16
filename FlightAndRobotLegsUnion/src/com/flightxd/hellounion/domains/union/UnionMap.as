package com.flightxd.hellounion.domains.union
{
	import assets.ChatView;
	
	import com.flightxd.hellounion.view.ChatViewMediator;
	
	import flash.display.DisplayObject;
	
	import flight.view.MediatorMap;

	/**
	 * @author John Lindquist
	 */
	public class UnionMap extends MediatorMap
	{
		public function UnionMap(context:DisplayObject = null)
		{
			super(context);
			map(ChatViewMediator, ChatView);
		}
	}
}
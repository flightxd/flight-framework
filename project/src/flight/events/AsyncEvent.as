package flight.events
{
	import flash.events.Event;
	
	public class AsyncEvent extends Event
	{
		public static const COMPLETE:String = "complete";
		public static const CANCEL:String = "cancel";
		
		//public static const RESULT:String = "result";
		//public static const FAULT:String = "fault";
		
		public function AsyncEvent(type:String, bubbles:Boolean, cancelable:Boolean)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}
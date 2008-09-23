package flight.services.remoting
{
	import flash.events.Event;

	public final class FaultEvent extends Event
	{
		
		public var fault:Object;
		
		public static const FAULT:String = "fault";
	
		public function FaultEvent (type:String, pFault:Object)
		{
			
			super (type, false, false);
			
			fault = pFault;
			
		}
		
	}
}
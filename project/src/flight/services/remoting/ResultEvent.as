package flight.services.remoting
{
	import flash.events.Event;

	public final class ResultEvent extends Event
	{
		
		public var result:Object;
		
		public static const RESULT:String = "result";
		
		public function ResultEvent (type:String, data:Object)
		{
			
			super (type, false, false);
			
			result = data;
			
		}
		
	}
}
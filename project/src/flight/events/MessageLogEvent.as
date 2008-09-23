package flight.events
{
	import flash.events.Event;

	public class MessageLogEvent extends Event
	{
		public static const LOG:String = 'message';
		
		private var _priority:int;
		private var _message:String;
		private var _details:Object;
		
		public function MessageLogEvent(type:String, priority:int, message:String, details:Object=null)
		{
			super(type);
			
			_priority = priority;
			_message = message;
			_details = details;
		}
		
		public function get priority():int
		{
			return _priority;
		}
		
		public function get message():String
		{
			return _message;
		}
		
		public function get details():Object
		{
			return _details;
		}
		
	}
}
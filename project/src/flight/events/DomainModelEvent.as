package flight.events
{
	import flash.events.Event;

	public class DomainModelEvent extends Event
	{
		public static const COMMIT:String = 'commit';
		
		public static const REVERT:String = 'revert';
		public static const EDIT:String = 'edit';
		public static const MERGE:String = 'merge';
		
		public function DomainModelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}
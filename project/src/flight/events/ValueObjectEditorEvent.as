package flight.events
{
	import flash.events.Event;

	public class ValueObjectEditorEvent extends Event
	{
		static public const COMMIT:String = 'commit';
		static public const MERGE:String = 'merge';
		static public const REVERT:String = 'revert';
		
		public function ValueObjectEditorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}
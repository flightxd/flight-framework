package flight.events
{
	import flash.events.Event;
	
	public class TargetEvent extends Event
	{
		override public function get currentTarget():Object
		{
			return super.currentTarget && _target && super.currentTarget == super.target ? _target : super.currentTarget;
		}
		
		private var _target:Object;
		override public function get target():Object
		{
			return super.target && _target ? _target : super.target;
		}
		
		private var _type:String;
		override public function get type():String
		{
			return _type || super.type;
		}
		
		public function TargetEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			_target = target;
			_type = type;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new TargetEvent(_type, bubbles, cancelable);
		}
	}
}

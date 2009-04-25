package flight.list
{
	import flight.events.FlightDispatcher;

	public class Selection extends FlightDispatcher implements ISelection
	{
		public function Selection()
		{
			super();
		}
		
		public function get index():int
		{
			return 0;
		}
		
		public function set index(value:int):void
		{
		}
		
		public function get item():Object
		{
			return null;
		}
		
		public function set item(value:Object):void
		{
		}
		
		public function get multiSelect():Boolean
		{
			return false;
		}
		
		public function set multiSelect(value:Boolean):void
		{
		}
		
		public function get indices():Array
		{
			return null;
		}
		
		public function set indices(value:Array):void
		{
		}
		
		public function get items():Array
		{
			return null;
		}
		
		public function set items(value:Array):void
		{
		}
		
	}
}
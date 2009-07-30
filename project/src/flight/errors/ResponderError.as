package flight.errors
{
	public class ResponderError extends Error
	{
		public var info:Object;
		
		public function ResponderError(info:Object = null)
		{
			super();
			this.info = info;
		}
		
	}
}
package flight.services
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	
	import flight.injection.Injector;
	
	import mx.core.IMXMLObject;

	public class Service extends EventDispatcher implements IMXMLObject
	{
		protected var context:DisplayObject;
		
		public function Service(context:DisplayObject = null)
		{
			if (context) initialized(context, null);
		}
		
		
		public function initialized(document:Object, id:String):void
		{
			context = document as DisplayObject;
			if (context) {
				Injector.provideInjection(this, context);
				Injector.inject(this, context);
			}
		}
	}
}
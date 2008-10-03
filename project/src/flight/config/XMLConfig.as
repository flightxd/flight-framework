package flight.config
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	dynamic public class XMLConfig extends Config
	{
		
		public function XMLConfig(source:String = null)
		{
			this.source = source;
		}
		
		public override function set source(value:Object):void
		{
			if(super.source == value)
				return;
			
			super.source = value;
			
			if (value is String)
			{
				// load
				var loader:URLLoader = new URLLoader();
				configureListeners(loader);
				loader.load(new URLRequest(value as String));
			}
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void
		{
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
//			dispatcher.addEventListener(Event.OPEN, openHandler);
//			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
//			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
//			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
//			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		private function completeHandler(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			configurations = formatSource(XML(loader.data));
		}
		
//		private function openHandler(event:Event):void
//		{
//			trace("openHandler: " + event);
//		}
//		
//		private function progressHandler(event:ProgressEvent):void
//		{
//			trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
//		}
//		
//		private function securityErrorHandler(event:SecurityErrorEvent):void
//		{
//			trace("securityErrorHandler: " + event);
//		}
//		
//		private function httpStatusHandler(event:HTTPStatusEvent):void
//		{
//			trace("httpStatusHandler: " + event);
//		}
//		
//		private function ioErrorHandler(event:IOErrorEvent):void
//		{
//			trace("ioErrorHandler: " + event);
//		}

	}
}
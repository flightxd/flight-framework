////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2009 Tyler Wright, Robert Taylor, Jacob Wright
//	
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//	
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

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
			this.source = [source];
		}
		
		public override function set source(value:Array):void
		{
			if (super.source == value) {
				return;
			}
			
			super.source = value;
			
			if (value is String) {
				// load
				var loader:URLLoader = new URLLoader();
				configureListeners(loader);
				loader.load(new URLRequest(value as String));
			}
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void
		{
			dispatcher.addEventListener(Event.COMPLETE, onComplete);
//			dispatcher.addEventListener(Event.OPEN, onOpen);
//			dispatcher.addEventListener(ProgressEvent.PROGRESS, onProgress);
//			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
//			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
//			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		private function onComplete(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			configurations = formatSource(XML(loader.data));
		}
		
//		private function onOpen(event:Event):void
//		{
//			trace("onOpen: " + event);
//		}
//		
//		private function onProgress(event:ProgressEvent):void
//		{
//			trace("onProgress loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
//		}
//		
//		private function onSecurityError(event:SecurityErrorEvent):void
//		{
//			trace("onSecurityError: " + event);
//		}
//		
//		private function onHttpStatus(event:HTTPStatusEvent):void
//		{
//			trace("onHttpStatus: " + event);
//		}
//		
//		private function onIOError(event:IOErrorEvent):void
//		{
//			trace("onIOError: " + event);
//		}

	}
}
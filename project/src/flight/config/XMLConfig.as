////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2009 Tyler Wright, Robert Taylor, Jacob Wright
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package flight.config
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	dynamic public class XMLConfig extends Config
	{
		private var _source:String;
		
		public function XMLConfig(source:String = null)
		{
			this.source = source;
		}
		
		[Bindable(event="sourceChange")]
		public function get source():String
		{
			return _source;
		}
		public function set source(value:String):void
		{
			if (_source == value) {
				return;
			}
			
			var oldValue:Object = _source;
			_source = value;
			
			// load XML file of configuration properties
			if (_source) {
				var loader:URLLoader = new URLLoader();
					loader.addEventListener(Event.COMPLETE, onComplete);
					loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
					loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					loader.load( new URLRequest(value) );
			}
			
			propertyChange("source", oldValue, _source);
		}
		
		private function onComplete(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			var children:XMLList = new XML(loader.data).children();
			var properties:Object = {};
			for each (var child:XML in children) {
				properties[child.name()] = child;
			}
			this.properties = properties;
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			trace(event.text);
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			trace(event.text);
		}

	}
}
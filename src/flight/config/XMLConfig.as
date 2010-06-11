/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

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
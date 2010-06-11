/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.config
{
	import flash.net.SharedObject;
	
	dynamic public class SharedObjectConfig extends Config
	{
		private var _sharedObject:SharedObject;
		private var _id:String;
		
		public function SharedObjectConfig(id:String = null)
		{
			this.id = id;
		}
		
		[Bindable(event="idChange")]
		public function get id():String
		{
			return _id
		}
		public function set id(value:String):void
		{
			if (_id == value) {
				return;
			}
			
			var oldValue:Object = _id;
			_id = value;
			
			if (_id) {
				_sharedObject = SharedObject.getLocal("config_" + _id);
				formatProperties(_sharedObject.data);
			}
			propertyChange("id", oldValue, _id);
		}
		
		override public function initialized(document:Object, id:String):void
		{
			super.initialized(document, id);
			
			if (id != null) {
				this.id = id;
			}
		}
		
		public function get sharedObject():SharedObject
		{
			return _sharedObject;
		}
	}
}
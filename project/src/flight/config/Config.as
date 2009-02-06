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
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	
	import flight.events.PropertyEvent;
	import flight.utils.Type;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.IMXMLObject;
	
	[DefaultProperty("source")]
	dynamic public class Config extends EventDispatcher implements IMXMLObject
	{
		private static const REGISTRY_SCOPE:String = "Config";
		
		public static var main:Config = new Config();
		
		private var _id:Object;
		private var _source:Array;
		
		private var _configurations:Object;
		private var _viewReference:DisplayObject;
		
		public function Config()
		{
			if (main != null) {
				main.source = main.source.concat(this);
			}
			
			source = [];
		}
		
		[Bindable(event="propertyChange", flight="true")]
		public function get configurations():Object
		{
			return _configurations;
		}
		public function set configurations(value:Object):void
		{
			if(_configurations == value) {
				return;
			}
			
var newValue:Object = {};

for (var i:String in _configurations) {
	newValue[i] = _configurations[i];
}

for (i in value) {
	newValue[i] = value[i];
	// subclass configs may not be dynamic, we will fail silently
	try {
		this[i] = value[i];
	} catch(e:Error) {
	}
}
			var oldValue:Object = _configurations;
			_configurations = newValue;
			PropertyEvent.dispatchChange(this, "configurations", oldValue, _configurations);
		}
		
		[Bindable(event="propertyChange", flight="true")]
		public function get source():Array
		{
			return _source;
		}
		public function set source(value:Array):void
		{
			if(_source == value) {
				return;
			}
			
if (value is Array) {
	var mainSourceAltered:Boolean = false;
	if (main && this != main) {
		var mainSource:Array = main.source.concat();
	}
	
	for each(var source:Config in value) {
		// let's not duplicate sources in main, they'll all filter up
		var index:int;
		if (mainSource && (index = mainSource.indexOf(source)) != -1) {
			mainSource.splice(index, 1);
			mainSourceAltered = true;
		}
		
		BindingUtils.bindSetter(update, source, "configurations");
	}
	
	if (mainSource && mainSourceAltered) {
		main.source = mainSource;
	}
}
			var oldValue:Array = _source;
			_source = value;
			PropertyEvent.dispatchChange(this, "source", oldValue, _source);
		}
		
		[Bindable(event="propertyChange", flight="true")]
		public function get viewReference():DisplayObject
		{
			return _viewReference;
		}
		public function set viewReference(value:DisplayObject):void
		{
			if(_viewReference == value) {
				return;
			}
			
			var oldValue:DisplayObject = _viewReference;
			_viewReference = value;
			PropertyEvent.dispatchChange(this, "viewReference", oldValue, _viewReference);
		}
		
		private var inited:uint;
		public function initialized(document:Object, id:String):void
		{
			if(id != null) {
				this._id = id;
			}
//			trace("Initialized", ++inited, "times");
			if(viewReference != null) {
				return;
			}
			if(document is DisplayObject) {
				viewReference = document as DisplayObject;
			}
			else if(document is Config) {
				BindingUtils.bindProperty(this, "viewReference", document, "viewReference");
			}
			
			// initialize the configurations object
			var configurations:Object = {};
			var propList:XMLList = getProperties();
			for each(var prop:XML in propList) {
				var name:String = prop.@name;
				configurations[name] = this[name];
			}
			this.configurations = configurations;
		}
		
		/**
		 * Format data pulled in from the source param to its native types (boolean etc.)
		 */
		protected function formatSource(source:Object):Object
		{
			var propList:XMLList = getProperties();
			
			for (var name:String in source) {
				var prop:XMLList = propList.(@name == name);
				var value:Object = source[name];
				if(value != null && prop.length()) {
					var type:Class = getDefinitionByName(prop.@type.toString()) as Class;
					source[name] = (type == Boolean && value == "false") ? false : type(value);
				}
			}
			
			return source;
		}
		
		// "data" is used as update is a bindSetter
		private function update(data:Object):void
		{
			// if the configurations have not been initialized yet (they are null or
			// or empty) then we won't process them yet
			if (data == null) {
				return;
			}
			
			var empty:Boolean = true;
			for (var prop:String in data) {
				empty = false;
				break;
			}
			
			if (empty) {
				return;
			}
			
			// can't just update using data, because of overrides, must do all sources
			var sources:Array = source as Array;
			var newConfigurations:Object = {};
			
			for each (var config:Config in sources) {
				// populate the dynamic properties
				var configurations:Object = config.configurations;
				for (var i:String in configurations) {
					newConfigurations[i] = configurations[i];
				}
			}
			
			this.configurations = newConfigurations;
		}
		
		protected function getProperties():XMLList
		{
			return Type.describeProperties(this)
					.(attribute('access') != 'readonly'
					&& attribute('declaredBy') != "flight.config::Config"
					&& !attribute('uri').length());
		}
	}
}

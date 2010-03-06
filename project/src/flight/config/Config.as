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
	import flash.display.DisplayObject;
	
	import flight.events.Dispatcher;
	import flight.events.PropertyEvent;
	import flight.injection.Injector;
	import flight.utils.Type;
	
	import mx.core.IMXMLObject;
	
	/**
	 * Config is the base class for all configurations, an easy way to popluate
	 * and access your application's initial settings. Each Config subtype is
	 * a single instance that (1) defines and/or (2) retreives a set of
	 * initialization properties. Config properties can be accessed either on
	 * the class instance through its Singleton getInstance(), or on Config's
	 * <code>main</code> configuration where all of the systems properties are
	 * available.
	 * 
	 * <p>The most common configurations define a set of properties on their
	 * class definition, either as ActionScript or MXML. These properties are
	 * most useful when first populated with default values, which may be
	 * overwritten once other configurations populate their <code>configs</code>
	 * list as decendants. This hierarchical structure flattens all properties
	 * upward to the top-most configuration, <code>Config.main</code>.</p>
	 * 
	 * <p>Certain subtypes of Config are built to retreive data from external
	 * sources, such as an XML file or parsed from the url of the web page.
	 * These more active configuration types are most often used within the
	 * <code>configs</code> list of another configuration.</p>
	 * 
	 * @see		#configs
	 */
	[DefaultProperty("configs")]
	dynamic public class Config extends Dispatcher implements IMXMLObject
	{
		/**
		 * Global configuration with access to all config properties within the
		 * system. The <code>main</code> config holds all configurations within
		 * its <code>configs</code> list.
		 */
		public static var main:Config = new Config();
		
		// the typeMap is used in formatting string-based properties
		private var typeMap:Object =
		{
			"true" :		true,
			"false" :		false,
			"NaN" :			NaN,
			"null" :		null,
			"undefined" :	undefined
		};
		
		private var _display:DisplayObject;
		
		private var _configs:Array = [];
		private var _properties:Object = {};
		
		
		public function Config(context:DisplayObject = null)
		{
			if (context != null) initialized(context, null);
			init();
		}
		
		/**
		 * Singleton initialization, establishing hierarchy with the global
		 * <code>main</code> config. Unlike the constructor this method is
		 * invoked only once for this type, despite the number of instances
		 * created.
		 */
		protected function init():void
		{
			// add every singleton config to the global 'main'
			if (main != null) {
				main.configs.push(this);
				main.updateProperties();
				addEventListener("propertiesChange", main.onPropertiesChange);
			}
			updateProperties();
		}
		
		/**
		 * Dynamic object holding all name/value pairs of properties available
		 * on this configuration, based on its own properties and those in its
		 * hierarchy. Replacing this object overwrites this configuration's
		 * property definitions as well as those above in hierarchy.
		 */
		[Bindable(event="propertiesChange")]
		public function get properties():Object
		{
			return _properties;
		}
		public function set properties(value:Object):void
		{
			if (_properties == value) {
				return;
			}
			
			// simple collection of values by name
			for (var i:String in value) {
				_properties[i] = value[i];
				
				// update the properties on the class
				try {
					this[i] = value[i];
				} catch (error:ReferenceError) {
					// subtype may not be dynamic or define this property, fail silently
				}
			}
			
			propertyChange("properties", _properties, _properties);
		}
		
		/**
		 * A list of supporting configurations that populate and overwrite this
		 * Config's properties. The <code>configs</code> list is resolved from
		 * the top to the bottom, where the bottom-most configuration in the
		 * <code>configs</code> list takes precedence over all properties
		 * previously set.
		 */
		[ArrayElementType("flight.config.Config")]
		[Bindable(event="configsChange")]
		public function get configs():Array
		{
			return _configs;
		}
		public function set configs(value:Array):void
		{
			if (_configs == value) {
				return;
			}
			
			var config:Config
			for each (config in _configs) {
				config.removeEventListener("propertiesChange", onPropertiesChange);
			}
			
			var oldValue:Array = _configs;
			_configs = value;
			
			for each (config in _configs) {
				// remove this sub-config from the main config - main will receive its
				// properties through the hierarchy
				var mainIndex:int = main.configs.indexOf(config);
				if (mainIndex != -1) {
					main.configs.splice(mainIndex, 1);
					config.removeEventListener("propertiesChange", main.onPropertiesChange);
				}
				config.addEventListener("propertiesChange", onPropertiesChange);
				if (config.display == null) {
					config.display = _display;
				}
			}
			updateProperties();
			
			propertyChange("configs", oldValue, _configs);
		}
		
		/**
		 * 
		 */
		[Bindable(event="displayChange")]
		public function get display():DisplayObject
		{
			return _display;
		}
		public function set display(value:DisplayObject):void
		{
			if (_display == value) {
				return;
			}
			
			var oldValue:DisplayObject = _display;
			_display = value;
			for each (var config:Config in _configs) {
				if (config.display == null) {
					config.display = _display;
				}
			}
			propertyChange("display", oldValue, _display);
		}
		
		public function initialized(document:Object, id:String):void
		{
			if (document is DisplayObject) {
				Injector.provideInjection(this, document as DisplayObject);
			}
			
			if (display != null && document is DisplayObject) {
				display = document as DisplayObject;
			}
			
			updateProperties();
		}
		
		/**
		 * Format data pulled in from the configs param to its native types (boolean etc.)
		 */
		protected function formatProperties(properties:Object):void
		{
			for (var i:String in properties) {
				
				var value:Object = properties[i];
				if ( !(value is String) ) {
					continue;
				}
				
				if ( !isNaN(Number(value)) ) {
					properties[i] = Number(value);
				} else if (value in typeMap) {
					properties[i] = typeMap[value];
				}
			}
			
			this.properties = properties;
		}
		
		protected function updateProperties():void
		{
			// can't just update using data, because of overrides, must do all configs
			var configProperties:Object = this == main ? {} : introspect();
			
			for each (var config:Config in _configs) {
				for (var i:String in config.properties) {
					configProperties[i] = config.properties[i];
				}
			}
			
			properties = configProperties;
		}
		
		private function introspect():Object
		{
			// initialize the properties object with class-defined properties
			var configProperties:Object = {};
			var propList:XMLList = Type.describeProperties(this)
					.(attribute("declaredBy").toString().indexOf("flight.config::") == -1);
			
			for each (var prop:XML in propList) {
				var i:String = prop.@name;
				configProperties[i] = this[i];
			}
			return configProperties;
		}
		
		private function onPropertiesChange(event:PropertyEvent):void
		{
			if (event.newValue != null) {
				updateProperties();
			}
		}
		
	}
}

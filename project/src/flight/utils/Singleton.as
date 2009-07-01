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

package flight.utils
{
	import flight.events.FlightDispatcher;
	
	import mx.core.IMXMLObject;
	
	public class Singleton extends FlightDispatcher implements IMXMLObject
	{
		public function Singleton()
		{
			var type:Class = getType(this);
			if (Registry.lookup(type) == null) {
				Registry.register(type, this);
				init();
			}
		}
		
		protected function init():void
		{
		}
		
		public function initialized(document:Object, id:String):void
		{
			if (id != null) {
				document[id] = getInstance(this);
			}
		}
		
		
		
		public static function getInstance(classObject:Object, scope:Object = null):Object
		{
			if ( !(classObject is Class) ) {
				classObject = getType(classObject);
			}
			
			var instance:Object = Registry.lookup(classObject, scope);
			if (instance == null) {
				instance = new classObject();
				Registry.register(classObject, instance, scope);
			}
			return instance;
		}
		
		public static function enforceSingleton(instance:Object, scope:Object = null):void
		{
			var classObject:Class = getType(instance);
			
			if (Registry.lookup(classObject, scope) == null) {
				Registry.register(classObject, instance, scope);
			} else {
				throw new Error(getClassName(classObject) + " class cannot be instantiated more than once.");
			}
		}
		
		public static function registerSubclass(classObject:Object, superclass:Class, scope:Object = null):Boolean
		{
			if ( !Type.isType(classObject, superclass) ) {
				return false;
			}
			if ( !(classObject is Class) ) {
				classObject = getType(classObject);
			}
			
			var instance:Object = Registry.lookup(superclass, scope);
			if ( !(instance is Class(classObject)) ) {
				instance = new classObject();
				Registry.register(superclass, instance, scope);
			}
			return true;
		}
		
	}
}
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

package flight.utils
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class Type
	{
		private static var typeCache:Dictionary = new Dictionary();
		private static var registeredTypes:Dictionary = new Dictionary();
		private static var inheritanceCache:Dictionary = new Dictionary();
		private static var propertyCache:Dictionary = new Dictionary();
		private static var methodCache:Dictionary = new Dictionary(); 
		
		public function Type()
		{
		}
		
		public static function equals(value1:Object, value2:Object):Boolean
		{
			if(value1 == value2) {
				return true;
			}
			
			Type.registerType(value1);
			
			var so1:ByteArray = new ByteArray();
	       	so1.writeObject(value1);
	        
			var so2:ByteArray = new ByteArray();
        	so2.writeObject(value2);
			
			return Boolean(so1.toString() == so2.toString());
		}
		
		public static function clone(value:Object):Object
		{
			Type.registerType(value);
			
			var so:ByteArray = new ByteArray();
	        so.writeObject(value);
	        
	        so.position = 0;
	        return so.readObject();
		}
		
		public static function isType(value:Object, type:Class):Boolean
		{
			if( !(value is Class) ) {
				return value is type;
			}
			
			if(value == type) {
				return true;
			}
			
			var inheritance:XMLList = describeInheritance(value);
			return Boolean( inheritance.(@type == getQualifiedClassName(type)).length() > 0 );
		}
		
		public static function getPropertyType(value:Object, property:String):Class
		{
			if( !(property in value) ) {
				return null;
			}
			
			// retrieve the correct property type from the property list
			var typeName:String = describeProperties(value).(@name == property)[0].@type;
			if(!typeName) {
				return null;
			}
			
			return getDefinitionByName(typeName) as Class;
		}
		
		public static function getTypeProperty(value:Object, type:Class):String
		{
			var typeName:String = getQualifiedClassName(type);
			
			// retrieve the correct type property from the property list
			var propList:XMLList = describeProperties(value).(@type == typeName);
			
			return (propList.length() > 0) ? propList[0].@name : "";
		}
		
		public static function registerType(value:Object):Boolean
		{
			if( !(value is Class) ) {
				value = getType(value);
			}
			
			if(!registeredTypes[value]) {		// no need to register a class more than once
				registeredTypes[value] = registerClassAlias(getQualifiedClassName(value).split("::").join("."), value as Class);
			}
			
			return true;
		}
		
		public static function describeType(value:Object):XML
		{
			if( !(value is Class) ) {
				value = getType(value);
			}
			
			if(typeCache[value] == null) {
				typeCache[value] = flash.utils.describeType(value);
			}
			
			return typeCache[value];
		}
		
		public static function describeInheritance(value:Object):XMLList
		{
			if( !(value is Class) ) {
				value = getType(value);
			}
			
			if(inheritanceCache[value] == null) {
				inheritanceCache[value] = describeType(value).factory.*.(localName() == "extendsClass" || localName() == "implementsInterface");
			}
			return inheritanceCache[value];
		}
		
		public static function describeProperties(value:Object, metadata:String = null):XMLList
		{
			if( !(value is Class) ) {
				value = getType(value);
			}
			
			if(propertyCache[value] == null) {
				propertyCache[value] = describeType(value).factory.*.(localName() == "accessor" || localName() == "variable");
			}
			
			if(metadata == null) {
				return propertyCache[value];
			}
			
			if(propertyCache[metadata] == null) {
				propertyCache[metadata] = new Dictionary();
			}
			if(propertyCache[metadata][value] == null) {
				propertyCache[metadata][value] = propertyCache[value].(child("metadata").(@name == metadata).length() > 0);
			}
			return propertyCache[metadata][value];
		}
		
		public static function describeMethods(value:Object, metadata:String = null):XMLList
		{
			if( !(value is Class) ) {
				value = getType(value);
			}
			
			if(methodCache[value] == null) {
				methodCache[value] = describeType(value).factory.method;
			}
			
			if(metadata == null) {
				return methodCache[value];
			}
			
			if(methodCache[metadata] == null) {
				methodCache[metadata] = new Dictionary();
			}
			if(methodCache[metadata][value] == null) {
				methodCache[metadata][value] = methodCache[value].(child("metadata").(@name == metadata).length() > 0);
			}
			return methodCache[metadata][value];
		}
		
	}
}
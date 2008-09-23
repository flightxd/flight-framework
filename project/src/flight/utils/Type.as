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
		private static var IDCache:Dictionary = new Dictionary();
		private static var typeCache:Dictionary = new Dictionary();
		private static var inheritanceCache:Dictionary = new Dictionary();
		private static var propertyCache:Dictionary = new Dictionary();
		private static var methodCache:Dictionary = new Dictionary(); 
		
		public function Type()
		{
		}
		
		public static function equals(value1:Object, value2:Object):Boolean
		{
			if(value1 == value2)
				return true;
			
			registerType(value1);
			var so1:ByteArray = new ByteArray();
	       	so1.writeObject(value1);
	        
	        registerType(value2);
			var so2:ByteArray = new ByteArray();
        	so2.writeObject(value2);
			
			return Boolean(so1.toString() == so2.toString());
		}
		
		public static function clone(value:Object):Object
		{
			registerType(so);
			var so:ByteArray = new ByteArray();
	        so.writeObject(value);
	        
	        so.position = 0;
	        return so.readObject();
		}
		
		public static function merge(fromValue:Object, toValue:Object):void
		{
			var propList:XMLList = describeProperties(fromValue);
			
			for each(var prop:XML in propList)
			{
				var name:String = prop.@name;
				if(name in fromValue && fromValue[name] !== undefined)
					toValue[name] = fromValue[name];
			}
		}
		
		public static function getID(value:Object):String
		{
			if(IDCache[value] == null)
			{
				// use the Type Coercion error to get the ActionScript object's internal object ID
				try { var coercion:Coercion = Coercion(value); } catch(e:Error)
				{
					IDCache[value] = e.message.split("@").pop().split(" ").shift();
				}
			}
			
			return IDCache[value];
		}
		
		public static function registerType(value:Object):void
		{
			registerClassAlias(getQualifiedClassName(value), getType(value));
		}
		
		public static function getType(value:Object):Class
		{
			if(value is Class)
				return value as Class;
			return value.constructor;
		}
		
		public static function getPropertyType(value:Object, property:String):Class
		{
			if( !(property in value) )
				return null;
			
			// retrieve the correct property type from the property list
			var type:String = describeProperties(value).(@name == prop)[0].@type;
			if(!type)
				return null;
			
			return getDefinitionByName(type) as Class;
		}
		
		public static function isType(value:Object, type:Class):Boolean
		{
			if( !(value is Class) )
				return value is type;
			
			if(value == type)
				return true;
			
			var inheritance:XMLList = describeInheritance(value);
			return Boolean( inheritance.(@type == getQualifiedClassName(type)).length() > 0 );
		}
		
		public static function describeType(value:Object):XML
		{
			if( !(value is Class) )
				value = getType(value);
			
			if(typeCache[value] == null)
				typeCache[value] = flash.utils.describeType(value);
			
			return typeCache[value];
		}
		
		public static function describeInheritance(value:Object):XMLList
		{
			if(inheritanceCache[value] == null)
				inheritanceCache[value] = describeType(value).factory.*.(localName() == "extendsClass" || localName() == "implementsInterface");
			return inheritanceCache[value];
		}
		
		public static function describeProperties(value:Object, metadataOnly:Boolean = false):XMLList
		{
			if(propertyCache[value] == null)
				propertyCache[value] = describeType(value).factory.*.(localName() == "accessor" || localName() == "variable");
			return (metadataOnly ? propertyCache[value].(child("metadata").length() > 0) : propertyCache[value]);
		}
		
		public static function describeMethods(value:Object, metadataOnly:Boolean = false):XMLList
		{
			if(methodCache[value] == null)
				methodCache[value] = describeType(value).factory.method;
			return (metadataOnly ? methodCache[value].(child("metadata").length() > 0) : methodCache[value]);
		}
		
	}
}

class Coercion {}
package flight.utils
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class Type
	{
		private static var typeCache:Dictionary = new Dictionary();
		private static var inheritanceCache:Dictionary = new Dictionary();
		private static var propertyCache:Dictionary = new Dictionary();
		private static var methodCache:Dictionary = new Dictionary(); 
		
		public function Type()
		{
		}
		
		public static function getType(value:Object):Class
		{
			if("constructor" in value)
				return value.constructor as Class;
			return getDefinitionByName( getQualifiedClassName(value) ) as Class;
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
		
		public static function describeType(value:Object):XML
		{
			if( !(value is Class) )
				value = Type.getType(value);
			
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
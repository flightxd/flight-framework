package flight.utils
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public function getType(value:Object):Class
	{
		if("constructor" in value)
			return value.constructor as Class;
		return getDefinitionByName( getQualifiedClassName(value) ) as Class;
	}
}
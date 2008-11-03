package flight.utils
{
	import flash.utils.getQualifiedClassName;
	
	public function getClassName(value:Object):String
	{
		return getQualifiedClassName(value).split("::").pop();
	}
}
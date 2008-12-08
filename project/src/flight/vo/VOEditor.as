package flight.vo
{
	import flash.utils.Dictionary;
	
	import flight.errors.InvalidConstructorError;
	import flight.utils.Type;
	import flight.vo.ValueObject;
	import flight.utils.getClassName;
	import flight.utils.getType;
	
	public class VOEditor
	{
		private static var source:Dictionary = new Dictionary(true);
		
		public function VOEditor()
		{
			InvalidConstructorError.staticConstructor(this);
		}
		
		public static function edit(target:ValueObject):ValueObject
		{
			var delegate:ValueObject = target.clone() as ValueObject;
			source[delegate] = target;
			return delegate;
		}
		
		public static function revert(delegate:ValueObject):void
		{
			if(source[delegate] != null)
				merge(source[delegate], delegate);
		}
		
		public static function commit(delegate:ValueObject):void
		{
			if(source[delegate] != null)
				merge(delegate, source[delegate]);
		}
		
		public static function merge(source:ValueObject, target:ValueObject):void
		{
			var type:Class = getType(source);
			if( !(target is type) )
				throw new TypeError("Attempted merge with incompatible type " + getClassName(type));
			
			var propList:XMLList = Type.describeProperties(source);
			
			for each(var prop:XML in propList)
			{
				var name:String = prop.@name;
				if(source[name] !== undefined)
				{
					target[name] = source[name];
				}
			}
		}
		
		public static function modified(delegate:ValueObject):Boolean
		{
			if(source[delegate] != null)
				return !delegate.equals(source[delegate]);
			return false;
		}
		
	}
}
package flight.domain
{
	import flight.utils.Type;
	import flight.utils.ValueObject;
	import flight.utils.getClassName;
	import flight.utils.getType;
	
	public class DomainModel extends ValueObject
	{
		private var source:DomainModel;
		
		public function DomainModel()
		{
		}
		
		public function edit():DomainModel
		{
			var delegate:DomainModel = clone() as DomainModel;
			delegate.source = this;
			return delegate;
		}
		
		public function revert():void
		{
			if(source)
				merge(source);
		}
				
		public function commit():void
		{
			if(source)
				source.merge(this);
		}
		
		public function merge(value:DomainModel):void
		{
			var type:Class = getType(value);
			if( !(this is type) )
				throw new TypeError("Attempted merge with incompatible type " + getClassName(type));
			
			var propList:XMLList = Type.describeProperties(value);
			
			for each(var prop:XML in propList)
			{
				var name:String = prop.@name;
				if(value[name] !== undefined)
				{
					if(this[name] is DomainModel)
						DomainModel(this[name]).merge(value[name]);
					else
						this[name] = value[name];
				}
			}
		}
		
		public function modified():Boolean
		{
			if(source != null)
				return !source.equals(this);
			return false;
		}
		
	}
}
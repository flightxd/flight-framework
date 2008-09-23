package flight.domain
{
	import flight.events.DomainModelEvent;
	import flight.utils.Type;
	import flight.utils.ValueObject;
	
	[Event(name="edit", type="flight.events.DomainModelEvent")]
	[Event(name="revert", type="flight.events.DomainModelEvent")]
	[Event(name="commit", type="flight.events.DomainModelEvent")]
	[Event(name="merge", type="flight.events.DomainModelEvent")]
	
	dynamic public class DomainModel extends ValueObject
	{
		private var source:DomainModel;
		
		public function DomainModel()
		{
		}
		
		public function edit():DomainModel
		{
			var delegate:DomainModel = clone() as DomainModel;
			delegate.source = this;
				
			dispatchEvent(new DomainModelEvent(DomainModelEvent.EDIT));	
				
			return delegate;
		}
		
		public function revert():void
		{
			if(source)
				merge(source);
				
			dispatchEvent(new DomainModelEvent(DomainModelEvent.REVERT));	
		}
				
		public function commit():void
		{
			if(source)
				source.merge(this);
			
			dispatchEvent(new DomainModelEvent(DomainModelEvent.COMMIT));
		}
		
		public function merge(value:Object):void
		{
			Type.merge(value, this);
			
			dispatchEvent(new DomainModelEvent(DomainModelEvent.MERGE));	
		}
		
		public function isModified():Boolean
		{
			if(source)
				return !source.equals(this);
			return false;
		}
		
	}
}
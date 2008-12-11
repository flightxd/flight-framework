package flight.list
{
	import flash.events.Event;
	
	import flight.vo.ValueObject;
	
	import mx.events.PropertyChangeEvent;
	
	public class ArrayContainer extends ValueObject implements IList
	{
		private var _source:Object;
		
		public function ArrayContainer(source:Object = null)
		{
			if(source != null)
				this.source = source;
		}
		
		[Bindable(event="propertyChange")]
		public function get source():Object
		{
			if(_source == null)
				_source = [];
			return _source;
		}
		public function set source(value:Object):void
		{
			if(_source == value)
				return;
			
			var oldValue:Object = _source;
			_source = value;
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "source", oldValue, value));
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get numItems():int
		{
			return source.length;
		}
		
		public function addItem(item:Object):Object
		{
			source.push(item);
			dispatchEvent(new Event(Event.CHANGE));
			return item;
		}
		
		public function addItemAt(item:Object, index:int):Object
		{
			source.splice(index, 0, item);
			dispatchEvent(new Event(Event.CHANGE));
			return item;
		}
		
		public function getItemAt(index:int):Object
		{
			return source[index];
		}
		
		public function getItemIndex(item:Object):int
		{
			return source.indexOf(item);
		}
		
		public function removeItem(item:Object):Object
		{
			return removeItemAt(source.indexOf(item));
		}
		
		public function removeItemAt(index:int):Object
		{
			var item:Object = source.splice(index, 1)[0];
			dispatchEvent(new Event(Event.CHANGE));
			return item;
		}
		
		public function removeItems():void
		{
			source.splice(0, source.length);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function setItemIndex(item:Object, index:int):Object
		{
			source.splice(source.indexOf(item), 1);
			return addItemAt(item, index);
		}
		
		public function swapItems(item1:Object, item2:Object):void
		{
			var index1:int = source.indexOf(item1);
			var index2:int = source.indexOf(item2);
			swapItemsAt(index1, index2);
		}
		
		public function swapItemsAt(index1:int, index2:int):void
		{
			var item1:Object = source[index1];
			var item2:Object = source[index2];
			
			if(index1 < index2)
			{
				source.splice(index2, 1);
				source.splice(index1, 1, item2);
				source.splice(index2, 0, item1);
			}
			else
			{
				source.splice(index1, 1);
				source.splice(index2, 1, item1);
				source.splice(index1, 0, item2);
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		override public function equals(value:Object):Boolean
		{
			var compare:Object = value is ArrayContainer ? ArrayContainer(value).source : value;
			for(var i:String in compare)
			{
				if(compare[i] != source[i])
					return false;
			}
			return true;
		}
		
		override public function clone():Object
		{
			return new ArrayContainer([].concat(source));
		}
	}
}

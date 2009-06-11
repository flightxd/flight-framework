package flight.list
{
	import flash.net.registerClassAlias;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.utils.getQualifiedClassName;
	
	import flight.events.FlightDispatcher;
	
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	/**
	 * Dispatched when the IList has been updated in some way.
	 * 
	 * @eventType					mx.events.CollectionEvent.COLLECTION_CHANGE
	 */
	[Event(name="collectionChange", type="mx.events.CollectionEvent")]
	
	[RemoteClass(alias="flight.list.Collection")]
	
	/**
	 * A simple implementation of IList that uses a backing Array, Vector or
	 * XMLList.
	 */
	public class Collection extends FlightDispatcher implements IList, IExternalizable
	{
		use namespace list_internal;
		
		// internally available to XMLListAdapter
		list_internal var _source:*;
		private var adapter:*;
		
		/**
		 * Construct a new Collection using the specified Array, Vector or
		 * XMLList as its source. If no source is specified an empty Array
		 * will be used.
		 */
		public function Collection(source:* = null)
		{
			this.source = source;
		}
		
		/**
		 * Get the number of items in the list.
		 * 
		 * @return	int			representing the length of the source.
		 */
		[Bindable(event="lengthChange")]
		public function get length():int
		{
			return adapter.length;
		}
		
		/**
		 * The source Array, Vector or XMLList for this Collection. Any changes
		 * done through the IList interface will be reflected in the source. If  
		 * no source is supplied the Collection will create an Array internally.
		 * Changes made directly to the underlying source (e.g., calling 
		 * <code>myCollection.source.pop()</code> will not cause <code>
		 * CollectionEvents</code> to be dispatched.
		 * 
		 * @return				An Array that represents the underlying source.
		 */
		[Bindable(event="sourceChange")]
		public function get source():*
		{
			return _source;
		}
		public function set source(value:*):void
		{
			if (value == null) {
				value = [];
			} else if (_source == value) {
				return;
			}
			
			var oldValue:Object = _source;
			
			if (value is XMLList) {
				_source = value;
				adapter = new XMLListAdapter(this);
			} else {
				_source = ("splice" in value) ? value : [value];
				adapter = _source;
			}
			
			propertyChange("source", oldValue, _source);
			
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
				event.kind = CollectionEventKind.RESET;
			dispatchEvent(event);
		}
		
		/**
		 * Add the specified item to the end of the list.
		 * 
		 * @param	item			the item to add
		 */
		public function addItem(item:Object):void
		{
			addItemAt(item, length);
		}
		
		/**
		 * Add the item at the specified index.  
		 * Any item that was after this index is moved out by one.  
		 * 
		 * @param	item			the item to place at the index
		 * @param	index			the index at which to place the item
		 */
		public function addItemAt(item:Object, index:int):void
		{
			var oldValue:Object = adapter.length;
			adapter.splice(index, 0, item);
			
			propertyChange("length", oldValue, adapter.length);
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
				event.kind = CollectionEventKind.ADD;
				event.items.push(item);
				event.location = index;
			dispatchEvent(event);
		}
		
		/**
		 * Get the item at the specified index.
		 * 
		 * @param	index			the index from which to retrieve the item
		 * @param	prefetch		unused in this implementation of IList.
		 * 
		 * @return					the item at the specified index
		 */
		public function getItemAt(index:int, prefetch:int=0):Object
		{
			return _source[index];
		}
		
		/**
		 * Returns the index of the item in the collection.
		 * 
		 * @param	item			the item to find
		 * 
		 * @return					the index of the item, or -1 if the item is
		 * 							unnavailable.
		 */
		public function getItemIndex(item:Object):int
		{
			return adapter.indexOf(item);
		}
		
		/**
		 * Currently not implemented.
		 */
		public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void
		{
		}
		
		/** 
		 *  Remove all items from the list.
		 */
		public function removeAll():void
		{
			var oldValue:Object = adapter.length;
			var items:* = adapter.splice(0, adapter.length);
			
			propertyChange("length", oldValue, adapter.length);
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
				event.kind = CollectionEventKind.RESET;
			dispatchEvent(event);
		}
		
		/**
		 * Removes the specified item from this list, should it exist.
		 * 
		 * @param	item			the item that should be removed
		 * @return					the item that was removed
		 */
		public function removeItem(item:Object):Object
		{
			return removeItemAt(adapter.indexOf(item));
		}
		
		/**
		 * Remove the item at the specified index and return it.
		 * Any items that were after this index are now one index earlier.
		 * 
		 * @param	index			the index from which to remove the item
		 * @return					the item that was removed
		 */
		public function removeItemAt(index:int):Object
		{
			var oldValue:Object = adapter.length;
			var item:Object = adapter.splice(index, 1)[0];
			
			propertyChange("length", oldValue, adapter.length);
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
				event.kind = CollectionEventKind.REMOVE;
				event.items.push(item);
				event.location = index;
			dispatchEvent(event);
			return item;
		}
		
		/**
		 * Moves the item to the specified index. Items at or above the index
		 * will advance a position to make room for the item.
		 * 
		 * @param	item			the item to move to the specified index
		 * @param	index			the index at which to place the item
		 * 
		 * @return					the item that was moved
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			var oldIndex:int = adapter.indexOf(item);
			if (oldIndex != -1) {
				adapter.splice(oldIndex, 1);
			} else {
				oldIndex = adapter.length;
			}
			
			adapter.splice(index, 0, item);
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
				event.kind = CollectionEventKind.MOVE;
				event.items.push(item);
				event.oldLocation = oldIndex;
				event.location = index;
			dispatchEvent(event);
			return item;
		}
		
		/**
		 * Return an Array that is populated in the same order as the IList
		 * implementation.
		 */ 
		public function toArray():Array
		{
			return adapter.concat() as Array;
		}
		
		/**
		 *  Ensures that only the source property is seralized.
		 *  @private
		 */
		public function readExternal(input:IDataInput):void
		{
			source = input.readObject();
		}
		
		/**
		 *  Ensures that only the source property is serialized.
		 *  @private
		 */
		public function writeExternal(output:IDataOutput):void
		{
			output.writeObject(_source);
		}

	}
}

import flight.list.Collection;

namespace list_internal;

class XMLListAdapter
{
	use namespace list_internal;
	
	public var source:XMLList;
	public var list:Collection;
	
	public function get length():uint
	{
		return source.length();
	}
	
	public function XMLListAdapter(list:Collection)
	{
		this.list = list;
		source = list.source;
	}
	
	public function indexOf(searchElement:*, fromIndex:int = 0):int
	{
		for (var i:int = 0; i < source.length(); i++) {
			if (source[i] == searchElement) {
				return i;
			}
		}
		return -1;
	}
	
	public function concat(... args):XMLList
	{
		var items:XMLList = source.copy();
		for each (var xml:Object in args) {
			items += xml;
		}
		return items;
	}
	
	public function push(... args):uint
	{
		for each (var node:XML in args) {
			source += node;
		}
		list._source = source;
		return source.length();
	}
	
	public function slice(startIndex:int = 0, endIndex:int = 0x7FFFFFFF):XMLList
	{
		if (startIndex < 0) {
			startIndex = Math.max(source.length() + startIndex, 0);
		}
		if (endIndex < 0) {
			endIndex = Math.max(source.length() + endIndex, 0);
		}
		
		// remove trailing items
		var items:XMLList = source.copy();
		while (endIndex < items.length()) {
			delete items[endIndex];
		}
		
		// now remove from the front
		endIndex = items.length() - startIndex;
		while (endIndex < items.length()) {
			delete items[0];
		}
		
		return items;
	}
		
	public function splice(startIndex:int, deleteCount:uint, ... values):XMLList
	{
		startIndex = Math.min(startIndex, source.length());
		if (startIndex < 0) {
			startIndex = Math.max(source.length() + startIndex, 0);
		}
		
		// remove deleted items
		var deletedItems:XMLList = new XMLList();
		for (var i:int = 0; i < deleteCount; i++) {
			deletedItems += source[startIndex];
			delete source[startIndex];
		}
		
		// build values to insert
		var insertedItems:XMLList = new XMLList();
		for each (var item:Object in values) {
			insertedItems += item;
		}
		source[startIndex] = (startIndex < source.length()) ?
							 insertedItems + source[startIndex] :
							 insertedItems;
		
		list._source = source;
		return deletedItems;
	}
	
}

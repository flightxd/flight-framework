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

package flight.list
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import flight.events.PropertyEvent;
	
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	use namespace flash_proxy;
	use namespace list_internal;
	
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
	public class Collection extends Proxy implements IList, IExternalizable
	{
		protected var dispatcher:EventDispatcher;
		
		list_internal var _source:*;	// internally available to XMLListAdapter
		
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
		 * Place the item at the specified index.  
	     * If an item was already at that index the new item will replace it and it 
	     * will be returned.
		 * 
		 * @param	item			item the new value for the index
		 * @param	index			the index at which to place the item
		 * 
		 * @return					the item that was replaced, null if none
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			var oldValue:Object = adapter.length;
			var oldItem:Object = adapter.splice(index, 1, item)[0];
			
			if (oldValue != adapter.length) {
				propertyChange("length", oldValue, adapter.length);
			}
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
				event.kind = CollectionEventKind.REPLACE;
				event.location = index;
				event.items.push(item, oldItem);
			dispatchEvent(event);
			return oldItem;
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
		
		
		override flash_proxy function getProperty(name:*):*
		{
			return _source[name];
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			_source[name] = value;
		}
		
		override flash_proxy function deleteProperty(name:*):Boolean
		{
			return delete _source[name];
		}
		
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return (name in _source);
		}
		
		override flash_proxy function callProperty(name:*, ... rest):*
		{
			return _source[name].apply(_source, rest);
		}
		
		override flash_proxy function nextName(index:int):String
		{
			return String(index - 1);
		}
		
		override flash_proxy function nextValue(index:int):*
		{
			return _source[index - 1];
		}
		
		override flash_proxy function nextNameIndex(index:int):int
		{
			return (index + 1) % (adapter.length + 1);
		}
		
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if (dispatcher == null) {
				dispatcher = new EventDispatcher(this);
			}
			
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if (dispatcher != null) {
				dispatcher.removeEventListener(type, listener, useCapture);
			}
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			if (dispatcher != null && dispatcher.hasEventListener(event.type)) {
				return dispatcher.dispatchEvent(event);
			}
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			if (dispatcher != null) {
				return dispatcher.hasEventListener(type);
			}
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			if (dispatcher != null) {
				return dispatcher.willTrigger(type);
			}
			return false;
		}
		
		protected function dispatch(type:String):Boolean
		{
			if (dispatcher != null && dispatcher.hasEventListener(type)) {
				return dispatcher.dispatchEvent( new Event(type) );
			}
			return false;
		}
		
		protected function propertyChange(property:String, oldValue:Object, newValue:Object):void
		{
			PropertyEvent.dispatchChange(this, property, oldValue, newValue);
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

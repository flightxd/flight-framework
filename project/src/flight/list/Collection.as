/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

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
	 * Dispatched when the Collection has been updated in some way.
	 * 
	 * @eventType	mx.events.CollectionEvent.COLLECTION_CHANGE
	 */
	[Event(name="collectionChange", type="mx.events.CollectionEvent")]
	
	[RemoteClass(alias="flight.list.Collection")]
	
	/**
	 * A simple implementation of Flex's IList that wraps an Array, Vector or
	 * XMLList.
	 * 
	 * @see		mx.collections.IList
	 */
	public class Collection extends Proxy implements IList, IExternalizable
	{
		/**
		 * Reference to the wrapped IEventDispatcher.
		 */
		protected var dispatcher:EventDispatcher;
		
		// internally available to XMLListAdapter
		list_internal var _source:*;
		
		private var adapter:*;
		
		/**
		 * Construct a new Collection using the specified Array, Vector or
		 * XMLList as its source. If no source is specified an empty Array
		 * will be created.
		 */
		public function Collection(source:* = null)
		{
			this.source = source;
		}
		
		/**
		 * The number of items in the list.
		 */
		[Bindable(event="lengthChange")]
		public function get length():int
		{
			return adapter.length;
		}
		
		/**
		 * The source Array, Vector or XMLList for this Collection. Changes made
		 * through the IList interface will be reflected by the source. If no  
		 * source is supplied the Collection will create an Array internally.
		 * 
		 * <p>Changes made directly to the underlying source (e.g., calling 
		 * <code>myCollection.source.pop()</code> will not cause
		 * <code>CollectionEvents</code> to be dispatched.</p>
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
		 * @param	item			The item to be added.
		 */
		public function addItem(item:Object):void
		{
			addItemAt(item, length);
		}
		
		/**
		 * Add the item at the specified index. Items on or following the index
		 * will be moved down by one.  
		 *   
		 * 
		 * @param	item			The item to be added.
		 * @param	index			The index at which to add the item.
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
		 * @param	index			The index from which to retrieve the item.
		 * @param	prefetch		Unused in this implementation of IList.
		 * 
		 * @return					The item at the specified index.
		 */
		public function getItemAt(index:int, prefetch:int=0):Object
		{
			return _source[index];
		}
		
		/**
		 * Returns the index of the item in the collection.
		 * 
		 * @param	item			The item to locate.
		 * 
		 * @return					The index of the item, or -1 if the item is
		 * 							not found.
		 */
		public function getItemIndex(item:Object):int
		{
			return adapter.indexOf(item);
		}
		
		/**
		 * Unused in this implementation of IList.
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
		 * Removes the specified item from this list.
		 * 
		 * @param	item			The item to remove.
		 * 
		 * @return					The item that was removed.
		 */
		public function removeItem(item:Object):Object
		{
			return removeItemAt(adapter.indexOf(item));
		}
		
		/**
		 * Remove the item at the specified index. Items following the index
		 * will be moved up by one.  
		 * 
		 * @param	index			The index from which to remove the item.
		 * @return					The item that was removed.
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
		 * Place the item at the specified index. If an item already exists at
		 * the specified location it will be replaced by the new item.
		 * 
		 * @param	item			The new item to set.
		 * @param	index			The index at which to place the item.
		 * 
		 * @return					The item that was replaced, or null.
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
		 * Return an Array that is populated in the same order as the list.
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
		
		// ========== Proxy Methods ========== //
		
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
		
		// ========== Dispatcher Methods ========== //
		
		/**
		 * Registers an event listener object with an EventDispatcher object so
		 * that the listener receives notification of an event. You can register
		 * event listeners on all nodes in the display list for a specific type
		 * of event, phase, and priority.
		 * 
		 * @param	type				The type of event.
		 * @param	listener			The listener function that processes the
		 * 								event.
		 * @param	useCapture			Determines whether the listener works in
		 * 								the capture phase or the target and
		 * 								bubbling phases.
		 * @param	priority			The priority level of the event
		 * 								listener.
		 * @param	useWeakReference	Determines whether the reference to the
		 * 								listener is strong or weak.
		 * 
		 * @see		flash.events.EventDispatcher#addEventListener
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if (dispatcher == null) {
				dispatcher = new EventDispatcher(this);
			}
			
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * Removes a listener from the Dispatcher object. If there is no
		 * matching listener registered with the Dispatcher object, a call
		 * to this method has no effect.
		 * 
		 * @param	type				The type of event.
		 * @param	listener			The listener object to remove.
		 * @param	useCapture			Specifies whether the listener was
		 * 								registered for the capture phase or the
		 * 								target and bubbling phases.
		 * 
		 * @see		flash.events.EventDispatcher#removeEventListener
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if (dispatcher != null) {
				dispatcher.removeEventListener(type, listener, useCapture);
			}
		}
		
		/**
		 * Dispatches an event into the event flow, but only if there is a
		 * registered listener. If the generic Event object is all that is 
		 * required the dispatch() method is recommended.
		 * 
		 * @param	event				The Event object that is dispatched into
		 * 								the event flow.
		 * 
		 * @return						A value of true if the event was
		 * 								successfully dispatched.
		 *  
		 * @see		flash.events.EventDispatcher#dispatchEvent
		 * @see		flight.events.Dispatcher#dispatch
		 */
		public function dispatchEvent(event:Event):Boolean
		{
			if (dispatcher != null && dispatcher.hasEventListener(event.type)) {
				return dispatcher.dispatchEvent(event);
			}
			return false;
		}
		
		/**
		 * Checks whether the Dispatcher object has any listeners
		 * registered for a specific type of event. This check is made before
		 * any events are dispatched.
		 * 
		 * @param	type				The type of event.
		 * 
		 * @return						A value of true if a listener of the
		 * 								specified type is registered; false
		 * 								otherwise.
		 * 
		 * @see		flight.events.EventDispatcher#hasEventListener
		 */
		public function hasEventListener(type:String):Boolean
		{
			if (dispatcher != null) {
				return dispatcher.hasEventListener(type);
			}
			return false;
		}
		
		/**
		 * Checks whether an event listener is registered with this
		 * Dispatcher object or any of its ancestors for the specified
		 * event type. Because ancesry is only available through the display
		 * list, this method behaves identically to hasEventListener().
		 * 
		 * @param	type				The type of event.
		 * 
		 * @return						A value of true if a listener of the
		 * 								specified type will be triggered; false
		 * 								otherwise.
		 * 
		 * @see		flight.events.EventDispatcher#willTrigger
		 */
		public function willTrigger(type:String):Boolean
		{
			if (dispatcher != null) {
				return dispatcher.willTrigger(type);
			}
			return false;
		}
		
		/**
		 * Creates and dispatches an event into the event flow, but only if
		 * there is a registered listener. Because a check for listeners is made
		 * before the event is created, this method is more optimized than
		 * dispatchEvent() for types that use the generic Event class.
		 * 
		 * @param	event				The Event object that is dispatched into
		 * 								the event flow.
		 * 
		 * @return						A value of true if the event was
		 * 								successfully dispatched.
		 *  
		 * @see		flight.events.Dispatcher#dispatchEvent
		 */
		protected function dispatch(type:String):Boolean
		{
			if (dispatcher != null && dispatcher.hasEventListener(type)) {
				return dispatcher.dispatchEvent( new Event(type) );
			}
			return false;
		}
		
		/**
		 * Creates and dispatches PropertyEvents in response to a property's
		 * change in value.
		 * 
		 * @see		flight.events.PropertyEvent#dispatchChange
		 */
		// TODO: complete documentation
		protected function propertyChange(property:String, oldValue:Object, newValue:Object):void
		{
			PropertyEvent.dispatchChange(this, property, oldValue, newValue);
		}
		
		/**
		 * Creates and dispatches PropertyEvents in response to a list of
		 * properties' changes in value.
		 * 
		 * @see		flight.events.PropertyEvent#dispatchChangeList
		 */
		// TODO: complete documentation
		protected function propertyListChange(properties:Array, oldValues:Array):void
		{
			PropertyEvent.dispatchChangeList(this, properties, oldValues);
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

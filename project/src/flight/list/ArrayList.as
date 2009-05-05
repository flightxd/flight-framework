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
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import flight.events.PropertyEvent;
	import flight.vo.IValueObject;

	public class ArrayList extends Proxy implements IList, IValueObject
	{
		use namespace list_internal;
		
		public var idField:String = "id";	// TODO: replace with dataMap
		
		protected var dispatcher:EventDispatcher;
		
		// internally available to XMLListAdapter
		list_internal var _source:*;
		private var adapter:*;
		
		public function ArrayList(source:* = null)
		{
			this.source = source;
		}
		
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
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get numItems():int
		{
			return adapter.length;
		}
		
		public function addItem(item:Object):Object
		{
			var oldValue:Object = adapter.length;
			adapter.push(item);
			propertyChange("numItems", oldValue, adapter.length);
			dispatchEvent(new Event(Event.CHANGE));
			return item;
		}
		
		public function addItemAt(item:Object, index:int):Object
		{
			var oldValue:Object = adapter.length;
			adapter.splice(index, 0, item);
			propertyChange("numItems", oldValue, adapter.length);
			dispatchEvent(new Event(Event.CHANGE));
			return item;
		}
		
		public function addItems(items:*, index:int=0x7FFFFFFF):*
		{
			var oldValue:Object = adapter.length;
			adapter.splice.apply(adapter, [index, 0].concat(items));
			propertyChange("numItems", oldValue, adapter.length);
			dispatchEvent(new Event(Event.CHANGE));
			return items;
		}
		
		public function getItemAt(index:int):Object
		{
			return _source[index];
		}
		
		public function getItemById(id:String):Object
		{
			for each (var item:Object in _source) {
				if (idField in item && item[idField] == id) {
					return item;
				}
			}
			return null;
		}
		
		public function getItemIndex(item:Object):int
		{
			return adapter.indexOf(item);
		}
		
		public function getItems(index:int=0, length:int=0x7FFFFFFF):*
		{
			if (index < 0) {
				index = Math.max(adapter.length + index, 0);
			}
			length = Math.max(length, 0);
			return adapter.slice(index, length+index);
		}
		
		public function removeItem(item:Object):Object
		{
			return removeItemAt(adapter.indexOf(item));
		}
		
		public function removeItemAt(index:int):Object
		{
			var oldValue:Object = adapter.length;
			var item:Object = adapter.splice(index, 1)[0];
			propertyChange("numItems", oldValue, adapter.length);
			dispatchEvent(new Event(Event.CHANGE));
			return item;
		}
		
		public function removeItems(index:int=0, length:int=0x7FFFFFFF):*
		{
			var oldValue:Object = adapter.length;
			var items:* = adapter.splice(index, length);
			propertyChange("numItems", oldValue, adapter.length);
			dispatchEvent(new Event(Event.CHANGE));
			return items;
		}
		
		public function setItemIndex(item:Object, index:int):Object
		{
			adapter.splice(adapter.indexOf(item), 1);
			adapter.splice(index, 0, item);
			dispatchEvent(new Event(Event.CHANGE));
			return item;
		}
		
		public function swapItems(item1:Object, item2:Object):void
		{
			var index1:int = adapter.indexOf(item1);
			var index2:int = adapter.indexOf(item2);
			swapItemsAt(index1, index2);
		}
		
		public function swapItemsAt(index1:int, index2:int):void
		{
			if (index1 > index2) {
				var temp:int = index1;
				index1 = index2;
				index2 = temp;
			}
			
			var item1:Object = _source[index1];
			var item2:Object = _source[index2];
			
			adapter.splice(index2, 1);
			adapter.splice(index1, 1, item2);
			adapter.splice(index2, 0, item1);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function equals(value:Object):Boolean
		{
			if ("source" in value) {
				value = value["source"];
			}
			
			for (var i:int = 0; i < adapter.length; i++) {
				if (_source[i] != value[i]) {
					return false;
				}
			}
			return true;
		}
		
		public function clone():Object
		{
			return new ArrayList( adapter.concat() );
		}
		
		flash_proxy override function getProperty(name:*):*
		{
			return _source[name];
		}
		
		flash_proxy override function setProperty(name:*, value:*):void
		{
			_source[name] = value;
		}
		
		flash_proxy override function deleteProperty(name:*):Boolean
		{
			return delete _source[name];
		}
		
		flash_proxy override function hasProperty(name:*):Boolean
		{
			return (name in _source);
		}
		
		flash_proxy override function callProperty(name:*, ... rest):*
		{
			return _source[name].apply(_source, rest);
		}
		
		flash_proxy override function nextName(index:int):String
		{
			return String(index - 1);
		}
		
		flash_proxy override function nextValue(index:int):*
		{
			return _source[index - 1];
		}
		
		flash_proxy override function nextNameIndex(index:int):int
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

import flash.utils.flash_proxy;

import flight.events.FlightDispatcher;
import flight.list.ArrayList;
import flight.list.IList;
import flight.list.ISelection;

namespace list_internal;

class XMLListAdapter
{
	use namespace list_internal;
	
	public var source:XMLList;
	public var list:ArrayList;
	
	public function get length():uint
	{
		return source.length();
	}
	
	public function XMLListAdapter(list:ArrayList)
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

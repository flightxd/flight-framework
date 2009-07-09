////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2009 Tyler Wright, Robert Taylor, Jacob Wright
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package flight.list
{
	import flight.events.FlightDispatcher;
	import flight.events.ListEvent;
	import flight.events.ListEventKind;
	import flight.events.PropertyEvent;
	
	/**
	 * 
	 */
	public class ListSelection extends FlightDispatcher implements IListSelection
	{
		private var list:IList;
		private var updatingLists:Boolean;
		private var _index:int = -1;
		private var _item:Object = null;
		private var _multiselect:Boolean = false;
		private var _indices:ArrayList = new ArrayList();
		private var _items:ArrayList = new ArrayList();
		
		public function ListSelection(list:IList)
		{
			this.list = list;
			list.addEventListener(ListEvent.LIST_CHANGE, onListChange, false, 0xF);
			_indices.addEventListener(ListEvent.LIST_CHANGE, onSelectionChange, false, 0xF);
			_items.addEventListener(ListEvent.LIST_CHANGE, onSelectionChange, false, 0xF);
		}
		
		[Bindable(event="indexChange")]
		public function get index():int
		{
			return _index;
		}
		public function set index(value:int):void
		{
			value = Math.max(-1, Math.min(list.numItems-1, value));
			if (_index == value) {
				return;
			}
			
			var oldValues:Array = [_index, _item];
			_index = value;
			_item = list.getItemAt(_index);
			
			updatingLists = true;
			_indices.source = [_index];
			_items.source = [_item];
			updatingLists = false;
			
			PropertyEvent.dispatchChangeList(this, ["index", "item"], oldValues);
		}
		
		[Bindable(event="itemChange")]
		public function get item():Object
		{
			return _item;
		}
		public function set item(value:Object):void
		{
			var i:int = list.getItemIndex(value);
			if (i == -1) {
				value = null;
			}
			if (_item == value) {
				return;
			}
			
			var oldValues:Array = [_item, _index];
			_item = value;
			_index = i;
			
			updatingLists = true;
			_items.source = [_item];
			_indices.source = [_index];
			updatingLists = false;
			
			PropertyEvent.dispatchChangeList(this, ["item", "index"], oldValues);
		}
		
		[Bindable(event="multiselectChange")]
		public function get multiselect():Boolean
		{
			return _multiselect;
		}
		public function set multiselect(value:Boolean):void
		{
			if (_multiselect == value) {
				return;
			}
			
			var oldValue:Object = _multiselect;
			_multiselect = value;
			propertyChange("multiselect", oldValue, _multiselect);
		}
		
		[Bindable(event="indicesChange")]
		public function get indices():IList
		{
			return _indices;
		}
		
		[Bindable(event="itemsChange")]
		public function get items():IList
		{
			return _items;
		}
		
		public function select(items:*):void
		{
			_items.source = items;
		}
		
		private function onListChange(event:ListEvent):void
		{
			var tmpItems:Array = [];
			for (var i:int = 0; i < _items.numItems; i++) {
				var item:Object = _items.getItemAt(i);
				var index:int = list.getItemIndex(item);
				
				if (index != -1) {
					tmpItems.push(item);
				}
			}
			
			_items.source = tmpItems;
		}
		
		private function onSelectionChange(event:ListEvent):void
		{
			if (updatingLists) {
				return;
			}
			
			var list1:ArrayList = event.target as ArrayList;
			if (!_multiselect && list1.numItems > 1) {
				list1.source = event.items != null ? event.items[0] : list1.getItemAt(0);
				event.stopImmediatePropagation();
				return;
			}
			
			var list2:ArrayList = (list1 == _indices) ? _items : _indices;
			var getData:Function = (list1 == _indices) ? list.getItemAt : list.getItemIndex;
			var tmpArray:Array;
			var tmpObject:Object;
			
			updatingLists = true;
			switch (event.kind) {
				case ListEventKind.ADD :
					tmpArray = [];
					for each (tmpObject in event.items) {
						tmpArray.push( getData(tmpObject) );
					}
					list2.addItems(tmpArray, event.location1);
					break;
				case ListEventKind.REMOVE :
					list2.removeItems(event.location1, event.items.length);
					break;
				case ListEventKind.MOVE :
					if (event.items.length == 1) {
						tmpObject = getData(event.items[0]);
						list2.setItemIndex(tmpObject, event.location1);
					} else {
						list2.swapItemsAt(event.location1, event.location2);
					}
					break;
				case ListEventKind.REPLACE :
					tmpObject = getData(event.items[0]);
					list2.setItemAt(tmpObject, event.location1);
					break;
				case ListEventKind.RESET :
					tmpArray = [];
					for (var i:int = 0; i < list1.numItems; i++) {
						tmpObject = list1.getItemAt(i);
						tmpArray.push( getData(tmpObject) );
					}
					list2.source = tmpArray;
					break;
			}
			updatingLists = false;
			
			var oldIndex:int = _index;
			var oldItem:Object = _item;
			_index = _indices.numItems > 0 ? _indices.getItemAt(0) as Number : -1;
			_item = _items.getItemAt(0);
			
			propertyChange("index", oldIndex, _index);
			propertyChange("item", oldItem, _item); 
		}
		
	}
}
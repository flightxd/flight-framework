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
	import flight.events.FlightDispatcher;
	import flight.events.ListEvent;
	import flight.events.ListEventKind;
	import flight.events.PropertyEvent;

	public class Selection extends FlightDispatcher implements ISelection
	{
		private var list:IList;
		private var updatingLists:Boolean;
		private var _index:int = -1;
		private var _item:Object = null;
		private var _multiselect:Boolean = false;
		private var _indices:ArrayList = new ArrayList();
		private var _items:ArrayList = new ArrayList();
		
		public function Selection(list:IList)
		{
			this.list = list;
			_indices.addEventListener(ListEvent.LIST_CHANGE, onIndicesChange, false, 0xF);
			_items.addEventListener(ListEvent.LIST_CHANGE, onItemsChange, false, 0xF);
		}
		
		[Bindable(event="index")]
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
			_indices.source = [_index];
			
			PropertyEvent.dispatchChangeList(this, ["index", "item"], oldValues);
		}
		
		[Bindable(event="item")]
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
			_items.source = [_item];
			
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
		
		[Bindable(event="indices")]
		public function get indices():IList
		{
			return _indices;
		}
		
		[Bindable(event="items")]
		public function get items():IList
		{
			return _items;
		}
		
		private function onIndicesChange(event:ListEvent):void
		{
			if (!_multiselect && _indices.numItems > 1) {
				_indices.source = event.items != null ? event.items[0] : _indices.getItemAt(0);
				event.stopImmediatePropagation();
				return;
			}
			
			var tmpItems:Array;
			var tmpIndex:int;
			
			switch (event.kind) {
				case ListEventKind.ADD :
					
					tmpItems = [];
					for each (tmpIndex in event.items) {
						tmpItems.push(list.getItemAt(tmpIndex));
					}
					_items.addItems(tmpItems, event.location1);
					
					break;
				case ListEventKind.REMOVE :
					_items.removeItems(event.location1, event.items.length);
					break;
				case ListEventKind.MOVE :
					if (event.items.length == 1) {
						var tmpItem:Object = list.getItemAt(event.items[0] as Number);
						_items.setItemIndex(tmpItem, event.location1);
					} else {
						_items.swapItemsAt(event.location1, event.location2);
					}
					break;
				case ListEventKind.RESET :
					tmpItems = [];
					for (var i:int = 0; i < _indices.numItems; i++) {
						tmpIndex = _indices.getItemAt(i) as Number;
						tmpItems.push(list.getItemAt(tmpIndex));
					}
					_items.source = tmpItems;
					break;
			}
			
			var oldValues:Array = [_index, _item];
			_index = _indices.getItemAt(0) as Number || -1;
			_item = list.getItemAt(_index);
			
			PropertyEvent.dispatchChangeList(this, ["index", "item"], oldValues); 
		}
		
		private function onItemsChange(event:ListEvent):void
		{
			if (!_multiselect && _items.numItems > 1) {
				_items.source = event.items != null ? event.items[0] : _items.getItemAt(0);
				event.stopImmediatePropagation();
				return;
			}
			
			var tmpIndices:Array;
			var tmpItem:Object;
			
			switch (event.kind) {
				case ListEventKind.ADD :
					
					tmpIndices = [];
					for each (tmpItem in event.items) {
						tmpIndices.push(list.getItemIndex(tmpItem));
					}
					_indices.addItems(tmpIndices, event.location1);
					
					break;
				case ListEventKind.REMOVE :
					_indices.removeItems(event.location1, event.items.length);
					break;
				case ListEventKind.MOVE :
					if (event.items.length == 1) {
						var tmpIndex:int = list.getItemIndex(event.items[0]);
						_indices.setItemIndex(tmpIndex, event.location1);
					} else {
						_indices.swapItemsAt(event.location1, event.location2);
					}
					break;
				case ListEventKind.RESET :
					tmpIndices = [];
					for (var i:int = 0; i < _items.numItems; i++) {
						tmpItem = _items.getItemAt(i);
						tmpIndices.push(list.getItemIndex(tmpItem));
					}
					_indices.source = tmpIndices;
					break;
			}
			
			var oldValues:Array = [_item, _index];
			_item = _items.getItemAt(0);
			_index = list.getItemIndex(_item);
			
			PropertyEvent.dispatchChangeList(this, ["item", "index"], oldValues);
		}
		
	}
}
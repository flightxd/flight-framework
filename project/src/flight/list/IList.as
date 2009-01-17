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
	public interface IList
	{
		function get numItems():int;
		function addItem(item:Object):Object;
		function addItemAt(item:Object, index:int):Object;
//		function addItems(items:Array, index:int = 0x7FFFFFFF):void;
		function getItemAt(index:int):Object;
//		function getItemById(id:String):Object;
		function getItemIndex(item:Object):int;
//		function getItems(index:int = 0, length:int = 0x7FFFFFFF):Array;
		function removeItem(item:Object):Object;
		function removeItemAt(index:int):Object;
//		function removeItems(index:int = 0, length:int = 0x7FFFFFFF):void;
		function removeItems():void;
		function setItemIndex(item:Object, index:int):Object;
		function swapItems(item1:Object, item2:Object):void
		function swapItemsAt(index1:int, index2:int):void
		
//		function get filterFunction():Function;
//		function set filterFunction(value:Function):void;
//		function get sort():Function;
//		function set sort(value:Function):void;
	}
}
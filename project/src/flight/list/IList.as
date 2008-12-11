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
package flight.observers
{
	import flash.events.IEventDispatcher;

	public interface IPropertyObservable
	{
		function addCheck(property:String, observerHost:IEventDispatcher, observer:Function):void;
		function removeCheck(property:String, observer:Function):void;
		
		function addHook(property:String, observerHost:IEventDispatcher, observer:Function):void;
		function removeHook(property:String, observer:Function):void;
		
		function addObserver(property:String, observerHost:IEventDispatcher, observer:Function):void;
		function removeObserver(property:String, observer:Function):void;
	}
}
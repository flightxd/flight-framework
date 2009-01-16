package flight.binding
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	public class Bind
	{
		private static var bindingIndex:Dictionary = new Dictionary(true);
		
		public function Bind()
		{
		}
		
		public static function addEventListener(dispatcher:IEventDispatcher, type:String, listener:Function,
												useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=true):void
		{
		}
		
		public static function removeEventListener(dispatcher:IEventDispatcher, type:String, listener:Function,
												   useCapture:Boolean=false):void
		{
		}
		
		public static function getBinding(source:Object, sourcePath:String, listener:Function = null):Binding
		{
			return new Binding(source, sourcePath, listener);
		}
		
		public static function addBinding(target:Object, targetPath:String, source:Object, sourcePath:String, twoWay:Boolean = false):Binding
		{
//			var binding2:Binding = new Binding(target, targetPath);
//			var binding:Binding = new Binding(source, sourcePath, binding2.setter);
//			if(twoWay)
//				binding2.addListener(binding.setter);
//			
//			binding.pairedBinding = binding2;
//			binding2.pairedBinding = binding;
//			
//			return binding;
			return null;
		}
		
		
		// build chain and listen to property changes along each link
		// any changes trigger chain rebuild and property evaluation
		// listening setter evaluates end+path to update property
		
		public static function bindEventListener(type:String, site:Object, listener:Function,
												 host:Object, chain:Object, useCapture:Boolean=false):void
		{
		}
		
		// all the removeBind, removeBindings, removeEvent, removeEvents, removeAll, etc..
		
		
	}
}

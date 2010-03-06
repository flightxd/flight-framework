package flight.view
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	
	import flight.binding.Bind;
	import flight.injection.IInjectorSubject;
	import flight.utils.Type;
	
	public class Mediator extends EventDispatcher implements IInjectorSubject
	{
		[Inject]
		[Bindable]
		public var target:DisplayObject;
		
		public function Mediator()
		{
			describeBindings(this);
			describePropertyListeners(this);
			describeEventListeners(this);
		}
		
		public function injected():void
		{
			init();
		}
		
		protected function init():void
		{
			
		}
		
		protected function bindProperty(target:String, source:String, twoWay:Boolean = false):void
		{
			Bind.addBinding(this, target, this, source, twoWay);
		}
		
		protected function bindPropertyListener(source:String, listener:Function):void
		{
			Bind.addListener(this, listener, this, source);
		}
		
		protected function bindEventListener(type:String, target:String, listener:Function,
											 useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
		{
			Bind.bindEventListener(type, listener, this, target, useCapture, priority, useWeakReference);
		}
		
		public function dispose():void
		{
			Bind.removeAllBindings(this);
			MediatorMap.releaseView(target);
		}
		
		
		
		// parses [Binding(source="source.path")] metadata
		public static function describeBindings(mediator:Mediator):void
		{
			var desc:XMLList = Type.describeProperties(mediator, "Binding");
			
			for each (var prop:XML in desc) {
				var meta:XMLList = prop.metadata.(@name == "Binding");
				
				// to support multiple Binding metadata tags on a single property
				for each (var tag:XML in meta) {
					var targ:String = ( tag.arg.(@key == "target").length() > 0 ) ?
										tag.arg.(@key == "target").@value :
										tag.arg.@value;
					
					Bind.addBinding(mediator, prop.@name, mediator, targ, true);
				}
			}
		}
		
		// parses [PropertyListener(source="source.path)] metadata
		public static function describePropertyListeners(mediator:Mediator):void
		{
			var desc:XMLList = Type.describeMethods(mediator, "PropertyListener");
			
			for each (var meth:XML in desc) {
				var meta:XMLList = meth.metadata.(@name == "PropertyListener");
				
				// to support multiple PropertyListener metadata tags on a single method
				for each (var tag:XML in meta) {
					var targ:String = ( tag.arg.(@key == "target").length() > 0 ) ?
										tag.arg.(@key == "target").@value :
										tag.arg.@value;
					
					Bind.addListener(mediator, mediator[meth.@name], mediator, targ);
				}
			}
		}
		
		// parses [EventListener(type="eventType", target="target.path")] metadata
		public static function describeEventListeners(mediator:Mediator):void
		{
			var desc:XMLList = Type.describeMethods(mediator, "EventListener");
			
			for each (var meth:XML in desc) {
				var meta:XMLList = meth.metadata.(@name == "EventListener");
				
				// to support multiple EventListener metadata tags on a single method
				for each (var tag:XML in meta) {
					var type:String = ( tag.arg.(@key == "type").length() > 0 ) ?
										tag.arg.(@key == "type").@value :
										tag.arg.@value;
					var targ:String = tag.arg.(@key == "target").@value;
					Bind.bindEventListener(type, mediator[meth.@name], mediator, targ);
				}
			}
		}
	}
}
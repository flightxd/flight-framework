package flight.view
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import flight.injection.Injector;
	import flight.observers.PropertyChange;
	
	import mx.core.IMXMLObject;
	
	/**
	 * MediatorMap maps mediator classes to view (DisplayObject) classes. It
	 * attaches to a DisplayObject context and listens to any display objects
	 * that get added to the stage under that. Whenever an instance of a view
	 * class is added to the stage MediatorMap will create the correct mediator
	 * and inject the view and any other injections needed into the mediator. 
	 */
	public class MediatorMap extends EventDispatcher implements IMXMLObject
	{
		protected static var mediatorContexts:Dictionary = new Dictionary(true);
		protected static var initializedViews:Dictionary = new Dictionary(true);
		
		protected var mapping:Dictionary = new Dictionary();
		
		
		public static function releaseView(view:DisplayObject):void
		{
			delete initializedViews[view];
		}
		
		
		/**
		 * Providing the MediatorMap with a display object will initialize it
		 * with that display object and any objects below it as they are added
		 * to the stage.
		 */
		public function MediatorMap(context:DisplayObject = null)
		{
			if (context) initialized(context, null);
			PropertyChange.addHook(DisplayObject, "injections", this, prepInjection);
		}
		
		/**
		 * Set a mapping between a mediator class and a view class. When a view
		 * of this type is placed on the display list a mediator of this type
		 * will be created for it.
		 */
		public function map(mediator:Class, view:Class):void
		{
			mapping[view] = mediator;
		}
		
		/**
		 * Get the mediator class for a given view class
		 */
		public function getMediator(view:Class):Class
		{
			return mapping[view];
		}
		
		/**
		 * Allow a MediatorMap to be placed in an MXML document and link itself
		 * up automatically.
		 */
		public function initialized(document:Object, id:String):void
		{
			var view:DisplayObject = document as DisplayObject;
			if (!view) return;
			
			var maps:Array = mediatorContexts[view];
			if (!maps) {
				mediatorContexts[view] = maps = [];
			}
			maps.push(this);
		}
		
		/**
		 * Create the mediators for views. If a view has already had its
		 * mediators created don't create them again. Once the mediators are
		 * created inject them.
		 */
		protected function match(view:DisplayObject, context:DisplayObject):Boolean
		{
			var type:Class = view["constructor"];
			
			if ( !(type in mapping) ) {
				return false;
			}
			
			var mediatorType:Class = mapping[type];
			var mediator:Object = new mediatorType();
			initializedViews[view] = mediator;
			Injector.provideInjection(view, context);
			Injector.inject(mediator, context);
			Injector.removeInjection(view, context);
			return true;
		}
		
		/**
		 * Before injection happens on a view, look for a mediator for it.
		 */
		protected static function prepInjection(view:DisplayObject, prop:String, oldValue:*, context:DisplayObject):void
		{
			if (view in initializedViews) return;
			
			var currentContext:DisplayObject = context;
			while (currentContext != null) {
				var maps:Array = mediatorContexts[currentContext];
				if (maps) {
					for each (var map:MediatorMap in maps) {
						if (map.match(view, context)) {
							return;
						}
					}
				}
				currentContext = currentContext.parent;
			}
		}
	}
}
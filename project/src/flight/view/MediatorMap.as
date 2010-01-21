package flight.view
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import flight.injection.Injector;
	
	import mx.core.IMXMLObject;
	
	/**
	 * MediatorMap maps mediator classes to view (DisplayObject) classes. It
	 * attaches to a DisplayObject context and listens to any display objects
	 * that get added to the stage under that. Whenever an instance of a view
	 * class is added to the stage MediatorMap will create the correct mediator
	 * and inject the view and any other injections needed into the mediator. 
	 */
	public class MediatorMap implements IMXMLObject
	{
		protected var mapping:Dictionary = new Dictionary();
		protected static var initializedViews:Dictionary = new Dictionary(true);
		
		
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
			
			// attach to the displayobject and listen for views being attached to the stage
			view.addEventListener(Event.ADDED_TO_STAGE, onViewAdded); // added for self
			view.addEventListener(Event.ADDED_TO_STAGE, onViewAdded, true); // added for children
			if (view.stage) {
				// root, already on stage.
				createMediator(view);
			}
		}
		
		/**
		 * When a view is added to the stage, create its mediator.
		 */
		protected function onViewAdded(event:Event):void
		{
			createMediator(event.target as DisplayObject);
		}
		
		/**
		 * Create the mediators for views. If a view has already had its
		 * mediators created don't create them again. Once the mediators are
		 * created inject them.
		 */
		protected function createMediator(view:DisplayObject):Object
		{
			var type:Class = view["constructor"];
			if (!(type in mapping) || view in initializedViews) return null;
			var mediatorType:Class = mapping[type];
			var mediator:Object = new mediatorType();
			initializedViews[view] = mediator;
			
			// allow the view to be injected into the mediator
			Injector.provideInjection(view, view);
			Injector.inject(mediator, view);
			Injector.removeInjection(view, view);
			return mediator;
		}
	}
}
package flight.injection
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import flight.observers.PropertyChange;
	import flight.utils.Type;
	
	import mx.core.IMXMLObject;
	
	/**
	 * Injector allows dependency injection to occure using the display list as
	 * a contextual separation point between instances. The display heirarchy
	 * allows an easy way to control context.
	 * 
	 * If an instance of Injector is added via MXML or created and passed a
	 * display object, it will inject any views added to the stage underneath
	 * the display object it is attached to.
	 * 
	 * A "subject" is an object which needs to be provided with instances of
	 * required Classes.
	 * 
	 * To "inject" a subject is to provide that subject with instances of objects
	 * that it is expecting of a certain type, belonging to its context.
	 * 
	 * An "injection" is an object that can be provided to subjects through inject.
	 * They are simply objects that have been registered in a certain context
	 * using the <code>provideInjection</code> method.
	 * 
	 * A "context" is a given display object including its parents on the
	 * display list. If an injection is providedd on the root of the application
	 * then any subject being injected under any context on the display list
	 * can receive that injection.
	 */
	public class Injector implements IMXMLObject
	{
		/**
		 * Keeps track of all injections for a context. Using the context as the
		 * key in a weak-reference dictionary will allow the injections to be
		 * garbage collected once the context is no longer referenced.
		 */
		protected static var registeredInjections:Dictionary = new Dictionary(true);
		
		protected static var registeredContexts:Dictionary = new Dictionary(true);
		
		/**
		 * Inject a subject with previously provided injections in its given
		 * context.
		 */
		public static function inject(subject:Object, context:DisplayObject):void
		{
			if (subject == null || context == null) {
				throw new ArgumentError("Injection subject and context cannot be null");
			}
			
			var change:PropertyChange = PropertyChange.begin();
			change.add(subject, "injections", null, context);
			
			var props:XMLList = Type.describeProperties(subject, "Inject");
			for each (var prop:XML in props) {
				var type:Class = getDefinitionByName(prop.@type) as Class;
				subject[prop.@name] = findInjection(type, context);
			}
			
			if (subject is IInjectorSubject) {
				IInjectorSubject(subject).injected();
			}
			
			if (subject is IEventDispatcher && IEventDispatcher(subject).hasEventListener("injected")) {
				IEventDispatcher(subject).dispatchEvent(new Event("injected"));
			}
			
			change.commit();
		}
		
		/**
		 * Provide an injection for the given context which will be injected in
		 * subjects later using the <code>inject</code> method.
		 */
		public static function provideInjection(injection:Object, context:DisplayObject):void
		{
			var injections:Array = registeredInjections[context];
			if (!injections) {
				registeredInjections[context] = injections = [];
			}
			
			injections.push(injection);
		}
		
		/**
		 * Remove an injection from being available that was previously provided.
		 */
		public static function removeInjection(injection:Object, context:DisplayObject):void
		{
			var injections:Array = registeredInjections[context];
			if (!injections) {
				return;
			}
			
			var index:int = injections.indexOf(injection);
			if (index != -1) {
				injections.splice(index, 1);
				if (injections.length == 0) {
					delete registeredInjections[context];
				}
			}
		}
		
		/**
		 * Finds an injection of a given type for a given context.
		 */
		protected static function findInjection(injectionType:Class, context:DisplayObject):Object
		{
			while (context) {
				var injections:Array = registeredInjections[context];
				if (injections) {
					for each (var injection:Object in injections) {
						if (injection is injectionType) {
							return injection;
						}
					}
				}
				context = context.parent;
			}
			return null;
		}
		
		/**
		 * Sets the context for a display object before it is added to the
		 * stage. By default the context is itself.
		 */
		public static function setContext(displayObject:DisplayObject, context:DisplayObject):void
		{
			registeredContexts[displayObject] = context;
		}
		
		/**
		 * Add a base display object to listen to the ADDED_TO_STAGE event. This
		 * will allow display objects to be injected as they come onto the
		 * display list. This only needs to be added once to a stage or to each
		 * window of an AIR application.
		 */
		public static function addBase(view:DisplayObject):void
		{
			if (view.stage) {
				view.stage.addEventListener(Event.ADDED_TO_STAGE, onViewAdded, true);
				injectView(view);
			} else {
				view.addEventListener(Event.ADDED_TO_STAGE, onViewFirstAdded);
				view.addEventListener(Event.ADDED_TO_STAGE, onViewAdded, true);
			}
		}
		
		/**
		 * Injects the views. Note that a view may be reused in several
		 * contexts and can be reinjected each time it is placed back onto the
		 * display list. This allows for views to be resused at runtime and
		 * still work correctly within the context they are placed.
		 */
		protected static function onViewFirstAdded(event:Event):void
		{
			var view:DisplayObject = event.target as DisplayObject;
			view.removeEventListener(Event.ADDED_TO_STAGE, onViewFirstAdded);
			view.removeEventListener(Event.ADDED_TO_STAGE, onViewAdded, true);
			view.stage.addEventListener(Event.ADDED_TO_STAGE, onViewAdded, true);
			injectView(view);
		}
		
		protected static function onViewAdded(event:Event):void
		{
			injectView(event.target as DisplayObject);
		}
		
		/**
		 * Injects the views. Note that a view may be reused in several
		 * contexts and can be reinjected each time it is placed back onto the
		 * display list. This allows for views to be resused at runtime and
		 * still work correctly within the context they are placed.
		 */
		protected static function injectView(view:DisplayObject):void
		{
			var basePackage:String = getQualifiedClassName(view).split('.').shift();
			if (basePackage != "mx" && basePackage != "flash" && basePackage != "spark") {
				inject(view, registeredContexts[view] || view);
			}
		}
		
		
		/**
		 * Allows for injection on display objects added to the display list.
		 */
		public function Injector(context:DisplayObject = null)
		{
			if (context) initialized(context, null);
		}
		
		/**
		 * Allows for a MXML tag for Injector to be placed at the root of an
		 * MXML application for automatic view injection.
		 */
		public function initialized(document:Object, id:String):void
		{
			// attach to the displayobject and listen for views being attached to the stage
			var view:DisplayObject = document as DisplayObject;
			if (view) {
				addBase(view);
			}
		}
	}
}
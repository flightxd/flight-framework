/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.utils
{
	import flight.events.Dispatcher;
	
	import mx.core.IMXMLObject;
	
	/**
	 * Utility class supporting the singleton design pattern. Through the
	 * Singleton's static members class authors can simplify and enforce the
	 * implementation of the pattern. By extending Singleton an object created
	 * in MXML will automatically replace itself with a global instance,
	 * offering an MXML-based solution for using singletons.
	 * 
	 * <p>Singleton classes should implement a static method getInstance()
	 * for ActionScript access. Only in MXML should Singleton's be created
	 * directly, where they require an id to ensure replacement.</p>
	 * 
	 * @see		#getInstance
	 */
	public class Singleton extends Dispatcher implements IMXMLObject
	{
		/**
		 * Singleton should only be instantiated internally or via MXML where
		 * it will be replaced (and only if it is assigned an 'id').
		 * ActionScript access should be through a static getIntance().
		 */
		public function Singleton()
		{
			var type:Class = getType(this);
			if (Registry.lookup(type) == null) {
				Registry.register(type, this);
				init();
			}
		}
		
		/**
		 * Called after a singleton has been created and instantiated and all
		 * class properties specified on the MXML tag have been initialized.
		 * 
		 * @param	document			The MXML document that created this
		 * 								Singleton object.
		 * @param	id					The identifier used by the MXML document
		 * 								to refer to this object.
		 */
		public function initialized(document:Object, id:String):void
		{
			if (id == null) {
//				trace("Warning: Singleton " + getClassName(this) + " 'id' is undefined in " +
//								getClassName(document) + ". MXML-instantiated singletons require an id.");
			} else {
				var type:Class = getType(this);
				document[id] = getInstance(type);
			}
		}
		
		/**
		 * The init() method is called upon the initial construction of a
		 * Singleton object, but only for the first instance created. Subsequent
		 * instances are discareded, and so should be minimal in their
		 * construction. The init() method should be overridden and implement
		 * all of an object's initialization. A classes constructor should
		 * remain empty.
		 */
		protected function init():void
		{
		}
		
		// ========== Static Methods ========== //
		
		/**
		 * Central retrieval method for all singletons, automatically creating
		 * and returning a single global instance. This method should be used
		 * by singleton implementations in their own getInstance() methods, as
		 * seen here:
		 * 
		 * <p>
		 * <pre>
		 * 	import flight.utils.Singleton;
		 * 	
		 * 	public static function getInstance():Custom
		 * 	{
		 * 		return Singleton.getInstance(Custom) as Custom;
		 * 	}
		 * </pre>
		 * </p>
		 * 
		 * @param	type				The class type to be returned as a
		 * 								singleton.
		 * @param	scope				Optionally tie global instances to this
		 * 								identifier, creating a limited scope
		 * 								within the global space.
		 * 
		 * @return						A singular class instance.
		 */
		public static function getInstance(type:Class, scope:Object = null):Object
		{
			var instance:Object = Registry.lookup(type, scope);
			if (instance == null) {
				instance = new type();
				Registry.register(type, instance, scope);
			}
			return instance;
		}
		
		/**
		 * Enforces singleton instantiation by throwing a run-time error on
		 * construction. For singleton implementations that will only be
		 * accessed via their static getInstance() method, not instantiated in
		 * MXML. Usage:
		 * 
		 * <p>
		 * <pre>
		 * 	import flight.utils.Singleton;
		 * 	
		 * 	// constructor
		 * 	public function Custom()
		 * 	{
		 * 		Singleton.enforceSingleton(this);
		 * 	}
		 * </pre>
		 * </p>
		 * 
		 * @param	instance			A reference to the class instance.
		 * @param	scope				Optionally tie global instances to this
		 * 								identifier, creating a limited scope
		 * 								within the global space.
		 */
		public static function enforceSingleton(instance:Object, scope:Object = null):void
		{
			var type:Class = getType(instance);
			
			if (Registry.lookup(type, scope) == null) {
				Registry.register(type, instance, scope);
			} else {
				throw new Error(getClassName(type) + " class cannot be instantiated more than once.");
			}
		}
		
		/**
		 * Allows a subclass to take the place of a superclass in singleton
		 * retrieval. Should be called as early as possible to ensure that the
		 * subclass takes precedence when the singleton is referenced. Useful
		 * for plugins and other extensions.
		 * 
		 * @param	type				The subclass type to be returned as a
		 * 								singleton in place of the superclass.
		 * @param	superclass			The superclass to be replaced.
		 * @param	scope				Optionally tie global instances to this
		 * 								identifier, creating a limited scope
		 * 								within the global space.
		 * 
		 * @return						Successful only with proper inheritance.
		 */
		public static function registerSubclass(type:Class, superclass:Class, scope:Object = null):Boolean
		{
			if ( !Type.isType(type, superclass) ) {
				return false;
			}
			
			var instance:Object = Registry.lookup(superclass, scope);
			if ( !(instance is type) ) {
				instance = new type();
				Registry.register(superclass, instance, scope);
			}
			return true;
		}
		
	}
}
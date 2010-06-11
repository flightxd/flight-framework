/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.utils
{
	import flash.utils.Dictionary; 
	
	/**
	 * The Registry is a global store for system-wide values and objects.
	 * Because Registry represents a static class it provides a single point of
	 * access everywhere. 
	 */
	public class Registry
	{
		// where system-wide values are stored by scope and index
		private static var scopeIndex:Dictionary = new Dictionary(true);
		private static var globalIndex:Dictionary = scopeIndex[null] = new Dictionary(true);
		private static var watcherByTarget:Dictionary = new Dictionary(true);
		private static var watcherByIndex:Dictionary = new Dictionary(true);
		
		/**
		 * Register data with some global identifier for system-wide lookup.
		 * 
		 * @param	index			String or object identifier with which to
		 * 							register and lookup data.
		 * @param	value			Data to be registered.
		 * @param	scope			Optionally register data to a specific scope
		 * 							identifier, creating a localized scope
		 * 							within the global space.
		 * 
		 * @see		#lookup
		 */
		public static function register(index:Object, value:Object, scope:Object = null):void
		{
			if (scopeIndex[scope] == null) {
				scopeIndex[scope] = new Dictionary(true);
			}
			
			scopeIndex[scope][index] = value;
			
			// update any "watching" for this particular 'index', on any scope
			for each (var syncDetail:Array in watcherByIndex[index]) {
				syncDetail[0][ syncDetail[1] ] = lookup(index, syncDetail[3]);
			}
		}
		
		/**
		 * Remove any data registered at the specified index and scope.
		 * 
		 * @param	index			String or object identifier with which to
		 * 							locate and remove data.
		 * @param	scope			Optionally remove data by a specific scope
		 * 							identifier, a localized scope within the
		 * 							global space.
		 * 
		 * @see		#register
		 */
		public static function unregister(index:Object, scope:Object = null):void
		{
			if (scopeIndex[scope] == null) {
				scopeIndex[scope] = new Dictionary(true);
			}
			
			delete scopeIndex[scope][index];
		}
		
		/**
		 * Retrieve data registered at the specified index and scope.
		 * 
		 * @param	index			String or object identifier with which to
		 * 							lookup registered data.
		 * @param	scope			Optionally lookup data by a specific scope
		 * 							identifier, a localized scope within the
		 * 							global space.
		 * 
		 * @return					Registered data.
		 * 
		 * @see		#register
		 */
		public static function lookup(index:Object, scope:Object = null):*
		{
			if (scope == null) {
				return scopeIndex[scope][index];
			}
			
			while (scope != null) {
				
				if (scopeIndex[scope] != null && index in scopeIndex[scope]) {
					return scopeIndex[scope][index];
				}
				
				if ("owner" in scope && scope["owner"] != null) {
					scope = scope["owner"];
				} else if ("parent" in scope) {
					if (scope["parent"] is Function) {
						scope = scope["parent"]();
					} else {
						scope = scope["parent"];
					}
				} else {
					return;
				}
			}
			
		}
		
		/**
		 * @private
		 * Possible deprecation.
		 */
		public static function sync(target:Object, prop:String, index:Object, scope:Object = null):void
		{
			desync(target, prop);
			var syncDetail:Array = arguments;
			
			if (watcherByIndex[index] == null) {
				watcherByIndex[index] = [];
			}
			watcherByIndex[index].push(syncDetail);
			
			if (watcherByTarget[target] == null) {
				watcherByTarget[target] = {};
			}
			watcherByTarget[target][prop] = syncDetail;
			
			target[prop] = lookup(index, scope);
		}
		
		/**
		 * @private
		 * Possible deprecation.
		 */
		public static function desync(target:Object, prop:String):void
		{
			var byTarget:Object = watcherByTarget[target];
			if (byTarget == null) {
				return;
			}
			
			var syncDetail:Array = byTarget[prop];
			if (syncDetail == null) {
				return;
			}
			
			var byIndex:Array = watcherByIndex[ syncDetail[2] ];
			byIndex.splice(byIndex.indexOf(syncDetail), 1);
			delete watcherByTarget[target][prop];
		}
	}
}

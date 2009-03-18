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

package flight.utils
{
	import flash.utils.Dictionary; 
	
	/**
	 * The Registry is a global store for system-wide values and objects.
	 * Because Registry is a static class it is a single point of access
	 * from anywhere. 
	 */
	public class Registry
	{
		private static var scopeIndex:Dictionary = new Dictionary();
		private static var watcherBySite:Dictionary = new Dictionary();
		private static var watcherByIndex:Dictionary = new Dictionary();
		
		public static function register(index:Object, value:Object, scope:Object = null):void
		{
			if(scopeIndex[scope] == null) {
				scopeIndex[scope] = new Dictionary();
			}
			
			scopeIndex[scope][index] = value;
			
			// update any "watching" for this particular 'index', on any scope
			for each(var syncDetail:Array in watcherByIndex[index]) {
				syncDetail[0][ syncDetail[1] ] = lookup(index, syncDetail[3]);
			}
		}
		
		public static function unregister(index:Object, scope:Object = null):void
		{
			if(scopeIndex[scope] == null) {
				scopeIndex[scope] = new Dictionary();
			}
			
			delete scopeIndex[scope][index];
		}
		
		public static function lookup(index:Object, scope:Object = null):*
		{
			if(scope != null) {
				var values:Dictionary = scopeIndex[scope];			// get values by scope (null is treated as the global scope)
				
				if(values != null && index in values) {
					return values[index];
				}
				
				if("owner" in scope && scope["owner"] != null) {
					return lookup(index, scope["owner"]);
				}
				if("parent" in scope && scope["parent"] != null) {
					return lookup(index, scope["parent"]);
				}
			}
			
			// check the global scope last (indexed by null)
			if(scopeIndex[null] == null) {
				scopeIndex[null] = new Dictionary();
			}
			return scopeIndex[null][index];
		}
		
		public static function sync(site:Object, prop:String, index:Object, scope:Object = null):void
		{
			desync(site, prop);
			var syncDetail:Array = arguments;
			
			if(watcherByIndex[index] == null) {
				watcherByIndex[index] = [];
			}
			watcherByIndex[index].push(syncDetail);
			
			if(watcherBySite[site] == null) {
				watcherBySite[site] = {};
			}
			watcherBySite[site][prop] = syncDetail;
			
			site[prop] = lookup(index, scope);
		}
		
		public static function desync(site:Object, prop:String):void
		{
			var bySite:Object = watcherBySite[site];
			if(bySite == null) {
				return;
			}
			
			var syncDetail:Array = bySite[prop];
			if(syncDetail == null) {
				return;
			}
			
			var byIndex:Array = watcherByIndex[ syncDetail[2] ];
			byIndex.splice(byIndex.indexOf(syncDetail), 1);
			delete watcherBySite[site][prop];
		}
		
	}
}

package flight.binding.utils
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.binding.utils.ChangeWatcher;
	
	public class BindingUtils
	{
		private static var endPoints:Dictionary = new Dictionary(true);
		
		public static function bindProperty(site:Object, prop:String, host:Object, chain:Object, useWeakReference:Boolean = false):ChangeWatcher
		{
			var changeWatcher:ChangeWatcher;
			if(useWeakReference)
			{
				var siteReference:BindProxy = new BindProxy(site);
				changeWatcher = siteReference.changeWatcher = mx.binding.utils.BindingUtils.bindProperty(siteReference, prop, host, chain);
			}
			else
				changeWatcher = mx.binding.utils.BindingUtils.bindProperty(site, prop, host, chain);
			
			if(endPoints[site] == null) endPoints[site] = [];
			endPoints[site].push(changeWatcher);
			
			if(endPoints[host] == null) endPoints[host] = [];
			endPoints[host].push(changeWatcher);
			return changeWatcher;
		}
		
		public static function bindSetter(site:Object, setter:Function, host:Object, chain:Object, useWeakReference:Boolean = false):ChangeWatcher
		{
			var changeWatcher:ChangeWatcher;
			if(useWeakReference)
			{
				if( !(site is IEventDispatcher) )
					throw new Error("Weak referenced bindSetter is available only for IEventDispatcher's. This limitation is a result of Flash Player's treatment of method closures within a Dictionary.");
				site.addEventListener("$bindSetter", setter);
				var setterReference:BindProxy = new BindProxy(setter);
				var proxySetter:Function = getProxySetter(setterReference);
				changeWatcher = setterReference.changeWatcher = mx.binding.utils.BindingUtils.bindSetter(proxySetter, host, chain);
			}
			else
				changeWatcher = mx.binding.utils.BindingUtils.bindSetter(setter, host, chain);
			
			if(endPoints[site] == null) endPoints[site] = [];
			endPoints[site].push(changeWatcher);
			
			if(endPoints[host] == null) endPoints[host] = [];
			endPoints[host].push(changeWatcher);
			return changeWatcher;
		}
		
		public static function bindTwoWay(endPoint1:Object, prop1:String, endPoint2:Object, prop2:String, useWeakReference:Boolean = false):void
		{
			bindProperty(endPoint1, prop1, endPoint2, prop2, useWeakReference);
			bindProperty(endPoint2, prop2, endPoint1, prop1, useWeakReference);
		}
		
		public static function bindEventListener(type:String, site:Object, listener:Function, host:Object, chain:Object, useCapture:Boolean=false):void
		{
			var dispatcher:DispatcherProxy = DispatcherProxy.getInstance(host, chain);
			dispatcher.addProxyListener(type, site, listener, useCapture);
		}
		
		public static function unbindEventListener(type:String, site:Object, listener:Function, host:Object, chain:Object, useCapture:Boolean=false):void
		{
			var dispatcher:DispatcherProxy = DispatcherProxy.getInstance(host, chain);
			dispatcher.removeProxyListener(type, site, listener, useCapture);
		}
		
		public static function setListening(site:Object, isListening:Boolean = true):void
		{
			if(isListening)
				delete DispatcherProxy.sitesBlocked[site];
			else
				DispatcherProxy.sitesBlocked[site] = true;
		}
		
		public static function releaseBindings(target:Object):void
		{
			var queue:Array = endPoints[target] as Array;
			if(queue != null)
			{
				for(var i:uint = 0; i < queue.length; i++)
				{
					ChangeWatcher(queue[i]).setHandler(null);
					ChangeWatcher(queue[i]).unwatch();
				}
			}
			delete endPoints[target];
		}
		
		private static function getProxySetter(setterReference:BindProxy):Function
		{
			return function(value:*):void
			{
				var setter:Function = setterReference.getItem() as Function;
				if(setter != null) setter(value);
			}
		}
		
	}
}


// Private Classes

import flash.utils.Dictionary;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import mx.binding.utils.ChangeWatcher;


dynamic class BindProxy extends Proxy
{
	public var changeWatcher:ChangeWatcher;
	
	private var setter:Boolean;
	private var dictionary:Dictionary;
	
	public function BindProxy(item:Object, setter:Boolean = false)
	{
		dictionary = new Dictionary(true);
		dictionary[item] = true;
		this.setter = setter;
	}
	
	override flash_proxy function setProperty(name:*, value:*):void
	{
		var item:Object = getItem();
		if(item == null) return;
		
		if(!setter)
			item[name] = value;
		else
			item[name](value);
	}
	
	public function getItem():*
	{
		for(var i:* in dictionary)
		{
			return i;
		}
		changeWatcher.setHandler(null);
		changeWatcher.unwatch();
	}
	
	public function toString():String
	{
		return "[object BindProxy]";
	}
	
}

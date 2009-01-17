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

package flight.binding.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	public class DispatcherProxy extends EventDispatcher
	{
		public static var hostIndex:Dictionary = new Dictionary(true);
		public static var sitesBlocked:Dictionary = new Dictionary(true);
		
		public static function getInstance(host:Object, chain:Object):DispatcherProxy
		{
			if(DispatcherProxy.hostIndex[host] == null) {
				DispatcherProxy.hostIndex[host] = [];
			}
			var chainIndex:Array = DispatcherProxy.hostIndex[host];
			
			// convert chain into an identifier to be used as an associative array index
			var chainId:String = (chain is Array) ? (chain as Array).join(".") : chain.toString();
			if(chainIndex[chainId] == null) {
				chainIndex[chainId] = new DispatcherProxy(host, chain);
			}
			
			return chainIndex[chainId];
		}
		
		private var dispatcher:IEventDispatcher;
		private var types:Array;
		private var typesCapture:Array;
		
		public function DispatcherProxy(host:Object, chain:Object)
		{
			types = [];
			typesCapture = [];
			BindingUtils.bindSetter(this, changeTarget, host, chain, true);
		}
		
		public function addProxyListener(type:String, site:Object, listener:Function, useCapture:Boolean=false):void
		{
			var index:int = listenerIndexOf(type, site, listener, useCapture);
			
			if(dispatcher is IEventDispatcher) {
				dispatcher.addEventListener(type, dispatchProxy, useCapture, 0, true);
			}
			var types:Array = useCapture ? typesCapture : this.types;
			var listeners:Array = types[type];
			
			if(index == -1) {
				listeners.push(new ListenerAttributes(type, site, listener, useCapture));
			} else {
				ListenerAttributes(listeners[index]).block = false;
			}
		}
		
		public function removeProxyListener(type:String, site:Object, listener:Function, useCapture:Boolean=false):void
		{
			var index:int = listenerIndexOf(type, site, listener, useCapture);
			if(index == -1) {
				return;
			}
			
			var types:Array = useCapture ? typesCapture : this.types;
			var listeners:Array = types[type];
			ListenerAttributes(listeners[index]).block = true;
		}
		
		private function dispatchProxy(event:Event):void
		{
			var types:Array = (event.eventPhase == EventPhase.CAPTURING_PHASE) ? typesCapture : this.types;
			var listeners:Array = types[event.type];
			var length:uint = listeners.length;
			for each(var attr:ListenerAttributes in listeners) {
				if( !sitesBlocked[attr.site] && !attr.block) {
					attr.listener(event);
				}
			}
		}
		
		private function listenerIndexOf(type:String, site:Object, listener:Function, useCapture:Boolean=false):int
		{
			var types:Array = useCapture ? typesCapture : this.types;
			var listeners:Array = types[type];
			if(listeners == null) {
				listeners = types[type] = [];
			}
			var length:uint = listeners.length;
			for(var i:uint = 0; i < length; i++) {
				var attr:ListenerAttributes = listeners[i];
				if(site == attr.site && listener == attr.listener && useCapture == attr.useCapture) {
					return i;
				}
			}
			return -1;
		}
		
		private function changeTarget(target:IEventDispatcher):void
		{
			var type:String;
			if(dispatcher is IEventDispatcher) {
				for(type in types) {
					dispatcher.removeEventListener(type, dispatchProxy, false);
				}
				for(type in typesCapture) {
					dispatcher.removeEventListener(type, dispatchProxy, true);
				}
			}
			
			dispatcher = target;
			
			if(dispatcher is IEventDispatcher) {
				for(type in types) {
					dispatcher.addEventListener(type, dispatchProxy, false, 0, true);
				}
				for(type in typesCapture) {
					dispatcher.addEventListener(type, dispatchProxy, true, 0, true);
				}
			}
		}
		
	}
}

class ListenerAttributes
{
	public var type:String;
	public var site:Object;
	public var listener:Function;
	public var useCapture:Boolean;
	
	public var block:Boolean;
	
	public function ListenerAttributes(type:String, site:Object, listener:Function, useCapture:Boolean=false)
	{
		this.type = type;
		this.site = site;
		this.listener = listener;
		this.useCapture = useCapture;
	}
}

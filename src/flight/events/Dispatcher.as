/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.events
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * The Dispatcher class is a base event dispatcher that optimizes the
	 * event flow.
	 * 
	 * <p>Dispatcher is an on-demand implementation of the
	 * IEventDispatcher interface. This means that the underlying
	 * EventDispatcher is not created until it is needed, conserving memory.
	 * Through Dispatcher events are not dispatched (or even created)
	 * unless htere are active listeners for the event.</p>
	 * 
	 * <p>Dispatcher also exposes property-change support.</p>
	 * 
	 * @see		flash.events.IEventDispatcher
	 */
	public class Dispatcher implements IEventDispatcher
	{
		/**
		 * Reference to the wrapped IEventDispatcher.
		 */
		protected var dispatcher:IEventDispatcher;
		
		/**
		 * Registers an event listener object with an EventDispatcher object so
		 * that the listener receives notification of an event. You can register
		 * event listeners on all nodes in the display list for a specific type
		 * of event, phase, and priority.
		 * 
		 * @param	type				The type of event.
		 * @param	listener			The listener function that processes the
		 * 								event.
		 * @param	useCapture			Determines whether the listener works in
		 * 								the capture phase or the target and
		 * 								bubbling phases.
		 * @param	priority			The priority level of the event
		 * 								listener.
		 * @param	useWeakReference	Determines whether the reference to the
		 * 								listener is strong or weak.
		 * 
		 * @see		flash.events.EventDispatcher#addEventListener
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if (dispatcher == null) {
				dispatcher = new EventDispatcher(this);
			}
			
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * Removes a listener from the Dispatcher object. If there is no
		 * matching listener registered with the Dispatcher object, a call
		 * to this method has no effect.
		 * 
		 * @param	type				The type of event.
		 * @param	listener			The listener object to remove.
		 * @param	useCapture			Specifies whether the listener was
		 * 								registered for the capture phase or the
		 * 								target and bubbling phases.
		 * 
		 * @see		flash.events.EventDispatcher#removeEventListener
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if (dispatcher != null) {
				dispatcher.removeEventListener(type, listener, useCapture);
			}
		}
		
		/**
		 * Dispatches an event into the event flow, but only if there is a
		 * registered listener. If the generic Event object is all that is 
		 * required the dispatch() method is recommended.
		 * 
		 * @param	event				The Event object that is dispatched into
		 * 								the event flow.
		 * 
		 * @return						A value of true if the event was
		 * 								successfully dispatched.
		 *  
		 * @see		flash.events.EventDispatcher#dispatchEvent
		 * @see		flight.events.Dispatcher#dispatch
		 */
		public function dispatchEvent(event:Event):Boolean
		{
			if (dispatcher != null && dispatcher.hasEventListener(event.type)) {
				return dispatcher.dispatchEvent(event);
			}
			return false;
		}
		
		/**
		 * Checks whether the Dispatcher object has any listeners
		 * registered for a specific type of event. This check is made before
		 * any events are dispatched.
		 * 
		 * @param	type				The type of event.
		 * 
		 * @return						A value of true if a listener of the
		 * 								specified type is registered; false
		 * 								otherwise.
		 * 
		 * @see		flight.events.EventDispatcher#hasEventListener
		 */
		public function hasEventListener(type:String):Boolean
		{
			if (dispatcher != null) {
				return dispatcher.hasEventListener(type);
			}
			return false;
		}
		
		/**
		 * Checks whether an event listener is registered with this
		 * Dispatcher object or any of its ancestors for the specified
		 * event type. Because ancesry is only available through the display
		 * list, this method behaves identically to hasEventListener().
		 * 
		 * @param	type				The type of event.
		 * 
		 * @return						A value of true if a listener of the
		 * 								specified type will be triggered; false
		 * 								otherwise.
		 * 
		 * @see		flight.events.EventDispatcher#willTrigger
		 */
		public function willTrigger(type:String):Boolean
		{
			if (dispatcher != null) {
				return dispatcher.willTrigger(type);
			}
			return false;
		}
		
		/**
		 * Creates and dispatches an event into the event flow, but only if
		 * there is a registered listener. Because a check for listeners is made
		 * before the event is created, this method is more optimized than
		 * dispatchEvent() for types that use the generic Event class.
		 * 
		 * @param	event				The Event object that is dispatched into
		 * 								the event flow.
		 * 
		 * @return						A value of true if the event was
		 * 								successfully dispatched.
		 *  
		 * @see		flight.events.Dispatcher#dispatchEvent
		 */
		protected function dispatch(type:String):Boolean
		{
			if (dispatcher != null && dispatcher.hasEventListener(type)) {
				return dispatcher.dispatchEvent( new Event(type) );
			}
			return false;
		}
		
		/**
		 * Creates and dispatches PropertyEvents in response to a property's
		 * change in value.
		 * 
		 * @see		flight.events.PropertyEvent#dispatchChange
		 */
		// TODO: complete documentation
		protected function propertyChange(property:String, oldValue:Object, newValue:Object):void
		{
			PropertyEvent.dispatchChange(this, property, oldValue, newValue);
		}
		
		/**
		 * Creates and dispatches PropertyEvents in response to a list of
		 * properties' changes in value.
		 * 
		 * @see		flight.events.PropertyEvent#dispatchChangeList
		 */
		// TODO: complete documentation
		protected function propertyListChange(properties:Array, oldValues:Array):void
		{
			PropertyEvent.dispatchChangeList(this, properties, oldValues);
		}
	}
}
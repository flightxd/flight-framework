////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2009 Tyler Wright, Robert Taylor, Jacob Wright
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package flight.events
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.binding.BindingManager;
	import mx.core.IPropertyChangeNotifier;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.utils.ObjectProxy;
	import mx.utils.UIDUtil;
	
	/**
	 * The PropertyChangeEvent class represents the event object
	 * passed to the event listener when one of the properties of
	 * an object has changed, and provides information about the change.
	 * This event is used by collection classes, and is the only way for
	 * collections to know that the data they represent has changed.
	 * This event is also used by the Flex data binding mechanism.
	 * 
	 * @see PropertyChangeEventKind
	 */
	public class PropertyEvent extends PropertyChangeEvent
	{
	    /**
	     *  The <code>PropertyChangeEvent.PROPERTY_CHANGE</code> constant defines the value of the 
	     *  <code>type</code> property of the event object for a <code>PropertyChange</code> event.
	     * 
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>Determined by the constructor; defaults to false.</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>Determined by the constructor; defaults to false.</td></tr>
	     *     <tr><td><code>kind</code></td><td>The kind of change; PropertyChangeEventKind.UPDATE
	     *             or PropertyChangeEventKind.DELETE.</td></tr>
	     *     <tr><td><code>oldValue</code></td><td>The original property value.</td></tr>
	     *     <tr><td><code>newValue</code></td><td>The new property value, if any.</td></tr>
	     *     <tr><td><code>property</code></td><td>The property that changed.</td></tr>
	     *     <tr><td><code>source</code></td><td>The object that contains the property that changed.</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	     *       event listener that handles the event. For example, if you use 
	     *       <code>myButton.addEventListener()</code> to register an event listener, 
	     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	     *       it is not always the Object listening for the event. 
	     *       Use the <code>currentTarget</code> property to always access the 
	     *       Object listening for the event.</td></tr>
	     *  </table>
	     *
	     *  @eventType propertyChange
	     *
	     */
		public static const _CHANGE:String = "Change";
		public static const PROPERTY_CHANGE:String = "propertyChange";
		
	    /**
	     *  Returns a new PropertyChangeEvent of kind
	     *  <code>PropertyChangeEventKind.UPDATE</code>
	     *  with the specified properties.
	     *  This is a convenience method.
	     * 
	     *  @param source The object where the change occured.
	     *
	     *  @param property A String, QName, or int
	     *  specifying the property that changed,
	     *
	     *  @param oldValue The value of the property before the change.
	     *
	     *  @param newValue The value of the property after the change.
	     *
	     *  @return A newly constructed PropertyChangeEvent
	     *  with the specified properties. 
	     */
		public static function dispatchChange(source:IEventDispatcher, property:Object, oldValue:Object, newValue:Object):void
		{
			var event:PropertyEvent;
			
			if ( source.hasEventListener(property + _CHANGE) ) {
				event = new PropertyEvent(property + _CHANGE, property, oldValue, newValue);
				source.dispatchEvent(event);
			}
			
			if ( source.hasEventListener(PROPERTY_CHANGE) ) {
				event = new PropertyEvent(PROPERTY_CHANGE, property, oldValue, newValue);
				source.dispatchEvent(event);
			}
		}
		
		/**
		 * 
		 */
		public static function dispatchChangeList(target:IEventDispatcher, properties:Array, oldValues:Array):void
		{
			for (var i:int = 0; i < properties.length; i++) {
				var property:Object = properties[i];
				var oldValue:Object = oldValues[i];
				var newValue:Object = target[property];
				if (oldValue != newValue || newValue is Array) {
			 		dispatchChange(target, property, oldValue, newValue);
			 	}
	 		}
		}
		
	    /**
	     *  Constructor.
	     *
	     *  @param type The event type; indicates the action that triggered the event.
	     *
	     *  @param bubbles Specifies whether the event can bubble
	     *  up the display list hierarchy.
	     *
	     *  @param cancelable Specifies whether the behavior
	     *  associated with the event can be prevented.
	     *
	     *  @param kind Specifies the kind of change.
	     *  The possible values are <code>PropertyChangeEventKind.UPDATE</code>,
	     *  <code>PropertyChangeEventKind.DELETE</code>, and <code>null</code>.
	     *
	     *  @param property A String, QName, or int
	     *  specifying the property that changed.
	     *
	     *  @param oldValue The value of the property before the change.
	     *
	     *  @param newValue The value of the property after the change.
	     *
	     *  @param source The object that the change occured on.
	     */
		public function PropertyEvent(type:String, property:Object, oldValue:Object, newValue:Object)
		{
			super(type, false, false, PropertyChangeEventKind.UPDATE, property, oldValue, newValue);
			return;
			
			// Compiler-required references to Flex classes for use of the
			// [Bindable] metadata tag in AS3-only projects - these classes are
			// never actually used, not even in the auto-generated code.
			BindingManager;
			IPropertyChangeNotifier;
			ObjectProxy;
			UIDUtil;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new PropertyEvent(type, property, oldValue, newValue);
		}
	}
}
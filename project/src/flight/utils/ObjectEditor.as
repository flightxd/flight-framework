/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.utils
{
	import flash.events.IEventDispatcher;
	
	import flight.events.Dispatcher;
	import flight.events.PropertyEvent;
	
	import mx.core.IMXMLObject;
	import mx.events.PropertyChangeEvent;
	
	/**
	 * Through the use of value-object's clone() and equals(), ObjectEditor
	 * copies, compares, and allows changes to be committed to some source
	 * object. This utility streamlines form and data editing by keeping
	 * modifications separate from the data source until a merge is appropriate.
	 * 
	 * <p>ObjectEditor objects are singular to the source they reference. By
	 * getting instances through the static edit() you can ensure that there is
	 * only one instance of ObjectEditor per source at any given time.</p>
	 * 
	 * @see		#edit
	 */
	public class ObjectEditor extends Dispatcher implements IMXMLObject
	{
		private var _target:Object;
		private var _source:Object;
		
		/**
		 * Construct a new ObjectEditor specific to the supplied data source.
		 * 
		 * @param	source			Optional data source to initialize with.
		 */
		public function ObjectEditor(source:Object = null)
		{
			this.source = source;
		}
		
		/**
		 * Indicator of whether the editor's target has been modified from its
		 * original source.
		 */
		[Bindable(event="modifiedChange")]
		public function get modified():Boolean
		{
			return (_source is IValueObject) ? !IValueObject(_source).equals(_target)
											 : !ValueObject.equals(_source, _target);
		}
		
		/**
		 * The target object of the editor is a copy of the source. This object
		 * is the target of all changes and can be committed, reverted or just
		 * discarded once editing is complete.
		 */
		[Bindable(event="targetChange")]
		public function get target():Object
		{
			return _target;
		}
		
		/**
		 * The source object of the editor represents some data source to be
		 * compared during editing. Changes to the data should be made on the
		 * editor's target and then committed, at which point the changes will
		 * be applied to the source.
		 */
		[Bindable(event="sourceChange")]
		public function get source():Object
		{
			return _source;
		}
		public function set source(value:Object):void
		{
			if (_source == value) {
				return;
			}
			
			var oldValues:Array = [modified, _target, _source];
			var registered:ObjectEditor = Registry.lookup(_source, ObjectEditor);
			
			// remove ties to the old source
			if (_source != null) {
				_target = null;
				if (_source is IEventDispatcher) {
					IEventDispatcher(_source).removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onChange);
					IEventDispatcher(_target).removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onChange);
				}
				
				// remove the global reference
				if (registered == this) {
					registered = null;
					Registry.unregister(_source, ObjectEditor);
					Registry.unregister(_target, ObjectEditor);
				}
			}
			
			_source = value;
			
			if (_source != null) {
				// register the global reference
				if (registered != null) {
					_target = registered._target;
				} else {
					Registry.register(_source, this, ObjectEditor);
					Registry.register(_target, this, ObjectEditor);
					// create the new target
					_target = (_source is IValueObject) ? IValueObject(_source).clone()
													   : ValueObject.clone(_source);
				}
				
				if (_source is IEventDispatcher) {
					IEventDispatcher(_source).addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onChange, false, 0, true);
					IEventDispatcher(_target).addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onChange, false, 0, true);
				}
			}
			
			PropertyEvent.dispatchChangeList(this, ["modified", "target", "source"], oldValues);
		}
		
		/**
		 * Merges all changes from the target to the source when editing is
		 * complete.
		 */
		public function commit():void
		{
			merge(_target, _source);
			source = null;
		}
		
		/**
		 * Merges the data source onto the target, reverting any changes made.
		 */
		public function revert():void
		{
			merge(_source, _target);
		}
		
		/**
		 * Discard both source and target objects, canceling changes and
		 * all editing.
		 */
		public function cancel():void
		{
			source = null;
		}
		
		/**
		 * Forces the modified property to refresh.
		 */
		public function refresh():void
		{
			propertyChange("modified", null, modified);
		}
		
		/**
		 * Called after an ObjectEditor has been created and instantiated and
		 * the source specified on the MXML tag has been initialized.
		 * 
		 * @param	document		The MXML document that created this
		 * 							ObjectEditor object.
		 * @param	id				The identifier used by the MXML document to
		 * 							refer to this object.
		 */
		public function initialized(document:Object, id:String):void
		{
			if (id != null && _source != null) {
				document[id] = edit(_source);
			}
		}
		
		/**
		 * General listener to source property changes.
		 */
		private function onChange(event:PropertyChangeEvent):void
		{
			refresh();
		}
		
		// ========== Static Methods ========== //
		
		/**
		 * Similar to the singleton, edit() returns a single global instance of
		 * ObjectEditor specific to the supplied source. Each data source will
		 * have its own ObjectEditor.
		 * 
		 * @param	source			The data source to wrap with an editor.
		 * 
		 * @return					An ObjectEditor specific to the source and
		 * 							ready with a cloned target for editing.
		 */
		public static function edit(source:Object):ObjectEditor
		{
			var registered:ObjectEditor = Registry.lookup(source, ObjectEditor) as ObjectEditor;
			if (registered == null) {
				registered = new ObjectEditor(source);
			}
			return registered;
		}
		
		/**
		 * Merges all changes from the target to the source when editing is
		 * complete.
		 * 
		 * @param	target			Editor's target or its data source.
		 * 
		 * @return					Success committing a valid ObjectEditor.
		 */
		public static function commit(target:Object):Boolean
		{
			var registered:ObjectEditor = Registry.lookup(target, ObjectEditor) as ObjectEditor;
			if (registered == null) {
				return false;
			}
			
			registered.commit();
			return true;
		}
		
		/**
		 * Merges the data source onto the target, reverting any changes made.
		 * 
		 * @param	target			Editor's target or its data source.
		 * 
		 * @return					Success reverting a valid ObjectEditor.
		 */
		public static function revert(target:Object):Boolean
		{
			var registered:ObjectEditor = Registry.lookup(target, ObjectEditor) as ObjectEditor;
			if (registered == null) {
				return false;
			}
			
			registered.revert();
			return true;
		}
		
		/**
		 * Discard both source and target objects, canceling changes and
		 * all editing.
		 * 
		 * @param	target			Editor's target or its data source.
		 * 
		 * @return					Success canceling a valid ObjectEditor.
		 */
		public static function cancel(target:Object):Boolean
		{
			var registered:ObjectEditor = Registry.lookup(target, ObjectEditor) as ObjectEditor;
			if (registered == null) {
				return false;
			}
			
			registered.cancel();
			return true;
		}
		
		/**
		 * Utility for merging the data of a source object to some target. The
		 * objects are not required to be of the same type, but should have
		 * compatible property signatures or the merge will fail. If the target
		 * implements the IMerging interface, its merge() method will be called.
		 * 
		 * @param	source			Any object with data to be merged.
		 * @param	target			Any object, will receive data from the
		 * 							source.
		 * 
		 * @see		flight.utils.IMerging
		 */
		public static function merge(source:Object, target:Object):void
		{
			if (source == null || target == null) {
				return;
			}
			
			if (target is IMerging) {
				IMerging(target).merge(source);
				return;
			}
			
			var name:String;
			var propList:XMLList = Type.describeProperties( source );
				propList = propList.(child("metadata").(@name == "Transient").length() == 0);
			
			// copy over class properties
			for each (var prop:XML in propList) {
				name = prop.@name;
				if (name in target && source[name] !== undefined) {
					if (target[name] is IValueObject && source[name] is IValueObject) {
						merge(target[name], source[name]);
					} else {
						target[name] = source[name];
					}
				}
			}
			
			// copy over dynamic properties
			for (name in source) {
				if (name in target && source[name] !== undefined) {
					if (target[name] is IValueObject && source[name] is IValueObject) {
						merge(target[name], source[name]);
					} else {
						target[name] = source[name];
					}
				}
			}
		}
		
	}
}

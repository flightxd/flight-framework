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

package flight.vo
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import flight.events.PropertyEvent;
	import flight.utils.Type;
	
	public class EditObject extends ValueObject
	{
		[Bindable(event="change")]
		public function get modified():Boolean
		{
			return EditObject.modified(this);
		}
		
		public function edit():Object
		{
			var editor:EditObject = EditObject.edit(this) as EditObject;
			addEventListener(PropertyEvent.PROPERTY_CHANGE, editor.onChange, false, 0, true);
			editor.addEventListener(PropertyEvent.PROPERTY_CHANGE, editor.onChange, false, 0, true);
			return editor;
		}
		
		public function commit():Boolean
		{
			var success:Boolean = EditObject.commit(this);
			dispatch(Event.CHANGE);
			return success;
		}
		
		public function revert():Boolean
		{
			var success:Boolean = EditObject.revert(this);
			dispatch(Event.CHANGE);
			return success;
		}
		
		private function onChange(event:Event):void
		{
			dispatch(Event.CHANGE);
		}
		
		
		private static var editorTargets:Dictionary = new Dictionary();
		public static function edit(target:IValueObject, editor:IValueObject = null):Object
		{
			if (editor == null) {
				editor = target.clone() as IValueObject;
			}
			editorTargets[editor] = target;
			return editor;
		}
		
		public static function commit(editor:IValueObject):Boolean
		{
			var target:IValueObject = editorTargets[editor];
			if (target == null) {
				return false;
			}
			
			merge(target, editor);
			return true;
		}
		
		public static function revert(editor:IValueObject):Boolean
		{
			var target:IValueObject = editorTargets[editor];
			if (target == null) {
				return false;
			}
			
			merge(editor, target);
			return true;
		}
		
		public static function modified(editor:IValueObject):Boolean
		{
			var target:IValueObject = editorTargets[editor];
			if (target == null) {
				return false;
			}
			
			return !editor.equals(target);
		}
		
		public static function merge(target:IValueObject, source:IValueObject):void
		{
			var name:String;
			var propList:XMLList = Type.describeProperties( source );
				propList = propList.(child("metadata").(@name == "Transient").length() == 0);
			
			// copy over class properties
			for each (var prop:XML in propList) {
				name = prop.@name;
				if (name in target && source[name] !== undefined) {
					if(target[name] is IValueObject && source[name] is IValueObject) {
						merge(target[name], source[name]);
					} else {
						target[name] = source[name];
					}
				}
			}
			
			// copy over dynamic properties
			for (name in source) {
				if (name in target && source[name] !== undefined) {
					if(target[name] is IValueObject && source[name] is IValueObject) {
						merge(target[name], source[name]);
					} else {
						target[name] = source[name];
					}
				}
			}
		}
		
	}
}

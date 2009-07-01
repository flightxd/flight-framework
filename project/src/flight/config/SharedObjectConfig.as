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

package flight.config
{
	import flash.net.SharedObject;
	
	dynamic public class SharedObjectConfig extends Config
	{
		private var _sharedObject:SharedObject;
		private var _id:String;
		
		public function SharedObjectConfig(id:String = null)
		{
			this.id = id;
		}
		
		[Bindable(event="idChange")]
		public function get id():String
		{
			return _id
		}
		public function set id(value:String):void
		{
			if (_id == value) {
				return;
			}
			
			var oldValue:Object = _id;
			_id = value;
			
			if (_id) {
				_sharedObject = SharedObject.getLocal("config_" + _id);
				formatProperties(_sharedObject.data);
			}
			propertyChange("id", oldValue, _id);
		}
		
		override public function initialized(document:Object, id:String):void
		{
			super.initialized(document, id);
			
			if (id != null) {
				this.id = id;
			}
		}
		
		public function get sharedObject():SharedObject
		{
			return _sharedObject;
		}
	}
}
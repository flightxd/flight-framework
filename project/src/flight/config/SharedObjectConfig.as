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

package flight.config
{
	import flash.net.SharedObject;
	
	dynamic public class SharedObjectConfig extends BaseConfig
	{
		private var _sharedObject:SharedObject;
		private var _id:Object;
		
		public function SharedObjectConfig(id:Object = null)
		{
			this.id = id;
		}
		
		// TODO: is this necessary? add binding, etc?
		public function set id(value:Object):void
		{
			if(_id == value) {
				return;
			}
			
			_id = value;
			
			_sharedObject = SharedObject.getLocal( "config_" + String(_id) );
			configurations = formatSource(sharedObject.data);
		}
		
		override public function initialized(document:Object, id:String):void
		{
			super.initialized(document, id);
			if(id != null) {
				this.id = id;
			}
		}
		
		public function get sharedObject():SharedObject
		{
			return _sharedObject;
		}
	}
}
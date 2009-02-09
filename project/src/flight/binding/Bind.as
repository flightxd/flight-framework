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

package flight.binding
{
	
	public class Bind
	{
		
		/**
		 * 
		 */
		public static function addBinding(target:Object, targetPath:String, source:Object, sourcePath:String, twoWay:Boolean = false):Boolean
		{
			var binding:Binding = Binding.getBinding(source, sourcePath);
			
			var success:Boolean;
			if(twoWay || targetPath.split(".").length > 1) {
				var binding2:Binding = Binding.getBinding(target, targetPath);
				
				success = binding.bind(binding2, "value");
				if(twoWay) {
					binding2.bind(binding, "value");
				} else {
					binding2.applyOnly = true;
				}
			} else {
				success = binding.bind(target, targetPath);
			}
			return success;
		}
		
		/**
		 * 
		 */
		public static function removeBinding(target:Object, targetPath:String, source:Object, sourcePath:String):Boolean
		{
			var binding:Binding = Binding.getBinding(source, sourcePath);
			var success:Boolean = binding.unbind(target, targetPath);
			
			if(!success) {
				var binding2:Binding = Binding.getBinding(target, targetPath);
				
				success = binding.unbind(binding2, "value");
				binding2.unbind(binding, "value");
				if( !binding2.hasBinds() ) {
					Binding.releaseBinding(binding2);
				}
			}
			
			if( !binding.hasBinds() ) {
				Binding.releaseBinding(binding);
			}
			return success;
		}
		
		/**
		 * 
		 */
		public static function addListener(listener:Function, source:Object, sourcePath:String):void
		{
			var binding:Binding = Binding.getBinding(source, sourcePath);
			binding.bindListener(listener);
		}
		
		/**
		 * 
		 */
		public static function removeListener(listener:Function, source:Object, sourcePath:String):void
		{
			var binding:Binding = Binding.getBinding(source, sourcePath);
			binding.unbindListener(listener);
			if( !binding.hasBinds() ) {
				Binding.releaseBinding(binding);
			}
		}
		
	}
}

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
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	dynamic public class FlashVarsConfig extends Config
	{
		public function FlashVarsConfig(display:DisplayObject = null)
		{
			this.display = display;
		}
		
		override public function set display(value:DisplayObject):void
		{
			if (super.display == value) {
				return;
			}
			
			if (value != null) {
				if (display.root != null) {
					formatProperties(display.root.loaderInfo.parameters);
				} else {
					display.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				}
			}
			super.display = value;
		}
		
		private function onAddedToStage(event:Event):void
		{
			formatProperties(display.root.loaderInfo.parameters);
			display.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
	}
}
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

package flight.domain
{
	import flash.events.Event;
	
	import flight.net.Response;
	
	[Event(name="execute", type="flash.events.Event")]

	public class ScriptCommand extends AsyncCommand
	{
		public var script:Function;
		public var params:Array;
		
		public function ScriptCommand(script:Function = null, params:Array = null)
		{
			this.script = script;
			this.params = params;
		}
		
		override public function execute():void
		{
			var result:Object = executeScript(script, params);
			
			if (result is Response) {
				response = result as Response;
			} else if (result is Error) {
				response.cancel(result as Error);
			} else {
				response.complete(result);
			}
		}
		
		protected function executeScript(script:Function, params:Array = null):*
		{
			if (script != null) {
				if (params != null) {
					return script.apply(null, [].concat(params));
				} else {
					return script();
				}
			}
			
			dispatchEvent(new Event("execute"));
		}
	}
}
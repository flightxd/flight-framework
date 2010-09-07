/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.commands
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
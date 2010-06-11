/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

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
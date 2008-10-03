package flight.config
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	dynamic public class FlashVarsConfig extends Config
	{
		public function FlashVarsConfig(viewReference:DisplayObject = null)
		{
			this.viewReference = viewReference;
		}
		
		override public function set viewReference(value:DisplayObject):void
		{
			super.viewReference = value;
			if(viewReference == null)
				return;
			
			if(viewReference.root != null)
				configurations = viewReference.root.loaderInfo.parameters;
			else
				viewReference.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function addedToStageHandler(event:Event):void
		{
			configurations = formatSource(viewReference.root.loaderInfo.parameters);
			viewReference.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
	}
}
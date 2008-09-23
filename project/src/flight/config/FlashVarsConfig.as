package flight.config
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class FlashVarsConfig extends Config
	{
		public function FlashVarsConfig(configView:DisplayObject = null)
		{
			this.configView = configView;
		}
		
		override public function set configView(value:DisplayObject):void
		{
			super.configView = value;
			if(configView == null)
				return;
			
			if(configView.root != null)
				configData = configView.root.loaderInfo.parameters;
			else
				configView.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function addedToStageHandler(event:Event):void
		{
			configData = configView.root.loaderInfo.parameters;
			configView.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
	}
}
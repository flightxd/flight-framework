package photoedit.editor.tools
{
	import flash.display.BlendMode;
	import flash.events.MouseEvent;
	
	import photoedit.editor.Editor;
	
	public class EraserTool extends BrushTool
	{
		public function EraserTool()
		{
		}
		
		protected override function press(evt:MouseEvent):void
		{
			if(selectedLayer == null)
			{
				// throw a warning to the user.
				trace("too many or no layers are selected");
				return;
			}
			super.press(evt);
			selectedLayer.blendMode = BlendMode.LAYER;
			selectedLayer.drawingContainer.blendMode = BlendMode.ERASE;
		}
		
		protected override function release(evt:MouseEvent):void
		{
			super.release(evt);
			selectedLayer.blendMode = BlendMode.NORMAL;
			selectedLayer.drawingContainer.blendMode = BlendMode.NORMAL;
		}
		
	}
}
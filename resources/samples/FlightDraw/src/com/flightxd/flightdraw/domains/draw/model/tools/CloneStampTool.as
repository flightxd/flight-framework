package photoedit.editor.tools
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class CloneStampTool extends BrushTool
	{
		protected var source:Point;
		protected var delta:Point;
		protected var refCanvas:Bitmap;
		
		public function CloneStampTool()
		{
			refCanvas = new Bitmap();
			refCanvas.cacheAsBitmap = true;
		}
		
		protected override function press(evt:MouseEvent):void
		{
			if(selectedLayer == null)
			{
				// throw a warning to the user.
				trace("too many or no layers are selected");
				return;
			}
			if(evt.altKey)
			{
				source = new Point(workArea.mouseX, workArea.mouseY);
				delta = null;
			}
			else if(source == null)
			{
				// throw a warning to the user.
				trace("source point has not been defined");
				return;
			}
			else
			{
				if(delta == null || !model.aligned)
					delta = new Point(workArea.mouseX, workArea.mouseY).subtract(source);
				
				var refBitmapData:BitmapData
				if(model.sample == "allLayers")
				{
					var options:Object = photoDocument.model.options;
					refBitmapData = new BitmapData(options.width.value, options.height.value);
					refBitmapData.draw(workArea);
					refCanvas.bitmapData = refBitmapData;
					refCanvas.x = refCanvas.y = 0;
				}
				else
				{
					refBitmapData = new BitmapData(selectedLayer.rect.width, selectedLayer.rect.height, true, 0x00000000);
					refBitmapData.draw(selectedLayer.canvas, new Matrix(1, 0, 0, 1, -selectedLayer.rect.x, -selectedLayer.rect.y));
					refCanvas.bitmapData = refBitmapData;
					refCanvas.x = selectedLayer.rect.x;
					refCanvas.y = selectedLayer.rect.y;
				}
				selectedLayer.drawingContainer.addChild(refCanvas);
				refCanvas.x += delta.x;
				refCanvas.y += delta.y;
				refCanvas.mask = selectedLayer.drawingLayer;
				super.press(evt);
			}
		}
		
		protected override function release(evt:MouseEvent):void
		{
			super.release(evt);
			refCanvas.mask = null;
			selectedLayer.drawingContainer.removeChild(refCanvas);
			refCanvas.bitmapData.dispose();
		}
		
	}
}
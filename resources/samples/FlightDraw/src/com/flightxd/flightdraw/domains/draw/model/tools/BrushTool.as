package photoedit.editor.tools
{
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	/**
	 * Base tool for many Photo tools. The BrushTool strokes ImageLayer's with a default (circular) brush
	 * or a custom (image) brush. Strokes can be use to add color to, erase, clone or filter an underlying image.
	 */
	public class BrushTool extends PhotoTool
	{
		protected var brushContainer:Sprite;
		protected var brushDisplay:DisplayObject;
		
		protected var mousePoint:Point;
		protected var mouseMoved:Number;
		protected var airbrushTime:uint;
		protected var airbrushInterval:int;
		
		protected var defaultBrush:Shape;
		protected var customBrush:Bitmap;
		
		public function BrushTool()
		{
			brushContainer = new Sprite();
			cursor = new Shape();
			cursor.blendMode = BlendMode.INVERT;
			
			bindEventListener(MouseEvent.MOUSE_DOWN, press, this, ["editor", "document", "workArea"]);
		}
		
		protected function press(evt:MouseEvent):void
		{
			if(selectedLayer == null)
			{
				// throw a warning to the user.
				trace("too many or no layers are selected");
				return;
			}
			
			renderBrush();
			brushContainer.addChildAt(brushDisplay, 0);
			if(document.selectionArea != null)
			{
				selectedLayer.addChild(document.selectionBitmap);
				selectedLayer.drawingContainer.mask = document.selectionBitmap;
			}
			
			mouseMoved = 0;
			mousePoint = new Point(selectedLayer.drawingLayer.mouseX, selectedLayer.drawingLayer.mouseY);
			brushDisplay.x = mousePoint.x;
			brushDisplay.y = mousePoint.y;
			selectedLayer.drawingLayer.bitmapData.draw(brushContainer);
			
			bindEventListener(MouseEvent.MOUSE_MOVE, drag, editor, ["document", "workArea", "stage"]);
			bindEventListener(MouseEvent.MOUSE_UP, release, editor, ["document", "workArea", "stage"]);
			if(model.airbrush)
			{
				airbrushTime = 2;
				airbrushInterval = setInterval(evaluateAirbrush, 80);
			}
		}
		
		protected override function moveCursor(evt:MouseEvent):void
		{
			if(evt.type == MouseEvent.ROLL_OVER)
			{
				var cursorGraphics:Graphics = Shape(cursor).graphics;
				cursorGraphics.clear();
				cursorGraphics.lineStyle(0, 0xFFFFFF, 1, true);
				cursorGraphics.drawCircle(0, 0, model.brush.diameter/2 * photoDocument.model.options.zoom/100);
			}
			super.moveCursor(evt);
		}
		
		protected function drag(evt:MouseEvent):void
		{
			var x1:Number = mousePoint.x;
			var y1:Number = mousePoint.y;
			var x2:Number = selectedLayer.drawingLayer.mouseX;
			var y2:Number = selectedLayer.drawingLayer.mouseY;
			var length:Number = model.brush.diameter / 4;
			
			var d:Number = Math.sqrt( Math.pow(x2-x1, 2) + Math.pow(y2-y1, 2) );
			
			var n:Number = length - mouseMoved;
			mousePoint = new Point(x2, y2);
			mouseMoved += d;
			airbrushTime = 0;
			
			while(d >= n)
			{
				brushDisplay.x = x1 + (x2-x1) / d * n;
				brushDisplay.y = y1 + (y2-y1) / d * n;
				selectedLayer.drawingLayer.bitmapData.draw(brushContainer);
				mouseMoved -= length;
				n += length;
			}
		}
		
		protected function release(evt:MouseEvent):void
		{
			unbindEventListener(MouseEvent.MOUSE_MOVE, drag, editor, ["document", "workArea", "stage"]);
			unbindEventListener(MouseEvent.MOUSE_UP, release, editor, ["document", "workArea", "stage"]);
			clearInterval(airbrushInterval);
			
			selectedLayer.commitLayer();
			
			if(document.selectionArea != null)
			{
				selectedLayer.removeChild(document.selectionBitmap);
				selectedLayer.drawingContainer.mask = null;
			}
			selectedLayer.drawingLayer.filters = [];
			selectedLayer.drawingLayer.alpha = 1;
		}
		
		protected function evaluateAirbrush():void
		{
			airbrushTime++;
			if(airbrushTime >= 2)
			{
				brushDisplay.x = selectedLayer.drawingLayer.mouseX;
				brushDisplay.y = selectedLayer.drawingLayer.mouseY;
				selectedLayer.drawingLayer.bitmapData.draw(brushContainer);
				if(airbrushTime % 8 == 0)
					selectedLayer.commitLayer();
			}
		}
		
		protected function renderBrush():void
		{
			if(model.brush.type != "brush")
				renderCustomBrush();
			else
				renderDefaultBrush();
		}
		
		protected function renderDefaultBrush():void
		{
			if(defaultBrush == null)
				defaultBrush = new Shape();
			
			defaultBrush.graphics.clear();
			defaultBrush.graphics.beginFill(0xFFFFFF);
			defaultBrush.graphics.drawCircle(0, 0, model.brush.diameter / 2 * (.66 + (model.brush.hardness/100)*.33));
			
			var blur:uint = model.brush.diameter * .2 * (1-(model.brush.hardness/100));
			//blur = (brush.hardness != 1) ? blur + 2 : 0;
			defaultBrush.filters = (blur != 0) ? [new BlurFilter(blur, blur, 3)] : [];
			
			var c:uint = photoEditor.foregroundColor;
			var colorMatrix:Array = 
						[0, 0, 0, 0, (c >> 16) & 0xFF,		// red
						0, 0, 0, 0, (c >> 8) & 0xFF,		// green
						0, 0, 0, 0, (c >> 0) & 0xFF,		// blue
						0, 0, 0, 1, 0];						// alpha
			selectedLayer.drawingLayer.filters = [new BlurFilter(blur, blur, 2), new ColorMatrixFilter(colorMatrix)];
			selectedLayer.drawingLayer.alpha = (model.opacity/100);
			
			brushDisplay = defaultBrush;
			if(model.hasOwnProperty("flow"))
				brushDisplay.alpha = (model.flow/100);
		}
		
		protected function renderCustomBrush():void
		{
			var colorMatrix:Array = [];
			selectedLayer.drawingLayer.filters = [new ColorMatrixFilter(colorMatrix)];
		}
		
	}
}

/*

Brush Tool (B)
* Master Diameter (1-2500 px)
* Hardness (0 - 100%)
* Mode (lighten, darken, difference)
* Opacity (1-100% opacity of the brush layer)
* Flow (1-100% opacity of brush stroke)
* AirBrush	... off (default), strokes every 25% of brush size in distance
			... on, also strokes 25% distance but also every 50ms or so when brush is paused.
* can hold default brush (circle w/diameter) or custom brush (image, no hardness setting)

*/
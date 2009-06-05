package com.flightxd.flightdraw.domains.draw.view
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	public class Document extends Canvas
	{
		public var toolArea:UIComponent;
		public var layer:Layer;
		
		protected var pattern:BitmapData;		// background pattern to draw below transparent layers
		
		
		public function Document()
		{
			toolArea = new UIComponent();
			addChild(toolArea);
			layer = new Layer();
			addChild(layer);
			
			// build a gray-white grid pattern to use behind transparent backgrounds
			pattern = new BitmapData(16, 16, false, 0xFFFFFF);
			pattern.fillRect(new Rectangle(0, 0, 8, 8), 0xCCCCCC);
			pattern.fillRect(new Rectangle(8, 8, 16, 16), 0xCCCCCC);
			
			setStyle("borderStyle", "solid");
			setStyle("borderThickness", "1");
			setStyle("borderColor", "#000000");
		}
		
		override public function set width(value:Number):void
		{
			if (super.width == value) {
				return;
			}
			
			super.width = value;
			updateCanvasSize();
		}
		
		override public function set height(value:Number):void
		{
			if (super.height == value) {
				return;
			}
			
			super.height = value;
			updateCanvasSize();
		}
		
		protected function updateCanvasSize():void
		{
			workArea.graphics.beginFill(0x000000, 0);
			workArea.graphics.drawRect(0, 0, width, height);
			
			layer.width = width;
			layer.height = height;
			drawBackground();
		}
		
		// transparent background: 8x8 0xcccccc
		protected function drawBackground():void
		{
			graphics.clear();
			graphics.beginBitmapFill(pattern);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
		}
		
	}
}
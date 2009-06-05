package com.flightxd.flightdraw.domains.draw.view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flight.binding.utils.BindingUtils;
	
	[Bindable]
	public class ImageLayer extends Layer
	{
		public var selectionArea:BitmapData;
		
		public var canvas:Shape;
		public var rect:Rectangle;
		
		public var layerMask:DisplayObject;
		public var drawingContainer:Sprite;
		public var drawingLayer:Bitmap;
		
		
		public function ImageLayer()
		{
			canvas = new Shape();
			drawingContainer = new Sprite();
			drawingLayer = new Bitmap();
			drawingContainer.cacheAsBitmap = true;
			drawingLayer.cacheAsBitmap = true;
			canvas.cacheAsBitmap = true;
			
			addChild(canvas);
			addChild(drawingContainer);
			drawingContainer.addChild(drawingLayer);
			BindingUtils.bindSetter(this, updateImage, this, ["model", "image"]);
			//BindingUtils.bindProperty(canvas, "bitmapData", this, ["model", "mask", "state, linked"]);
		}
		
		public override function getRect(targetCoordinateSpace:DisplayObject):Rectangle
		{
			return canvas.getRect(targetCoordinateSpace);
		}
		
		public function commitLayer():void
		{
			canvas.transform.matrix = transform.matrix;
			transform.matrix = new Matrix();
			rect = drawingLayer.bitmapData.getColorBoundsRect(0xFF000000, 0x00000000, false);
			rect = rect.union(canvas.getRect(this));
			
			var bmp:BitmapData = new BitmapData(width, height, true, 0x00000000);
			var filtersList:Array = filters;
			filters = [];
			bmp.draw(this);
			filters = filtersList;
			model.image = bmp;
			canvas.transform.matrix = new Matrix();
			
			bmp = new BitmapData(drawingLayer.width, drawingLayer.height, true, 0x00000000);
			drawingLayer.bitmapData.dispose();
			drawingLayer.bitmapData = bmp;
		}
		
		public function getSelectedPixels():BitmapData
		{
			var selectedPixels:BitmapData = new BitmapData(width, height, true, 0x00000000);
			if(selectionArea != null)
			{
				var selBitmap:Bitmap = new Bitmap(selectionArea);
				addChild(selBitmap);
				selBitmap.cacheAsBitmap = true;
				canvas.mask = selBitmap;
				selectedPixels.draw(this);
				canvas.mask = null;
				removeChild(selBitmap);
			}
			else
				selectedPixels.draw(this);
			return selectedPixels;
		}
		
		public function eraseSelectedPixels():void
		{
			if(selectionArea == null)
				return;
			
			var selBitmap:Bitmap = new Bitmap(selectionArea);
			addChild(selBitmap);
			blendMode = BlendMode.LAYER;
			selBitmap.blendMode = BlendMode.ERASE;
			commitLayer();
			
			blendMode = BlendMode.NORMAL;
			selBitmap.blendMode = BlendMode.NORMAL;
			removeChild(selBitmap);
		}
		
		protected function updateImage(image:BitmapData):void
		{
			canvas.graphics.clear();
			if(image)
			{
				rect = image.transparent ? image.getColorBoundsRect(0xFF000000, 0x00000000, false) : image.rect.clone();
				canvas.graphics.beginBitmapFill(image);
				canvas.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			}
		}
		
		protected override function validate():void
		{
			if(drawingLayer.bitmapData != null)
			{
				var pos:Point = new Point(.5,.5);
				rect.x += (width - drawingLayer.width) * pos.x;
				rect.y += (height - drawingLayer.height) * pos.y;
				drawingLayer.bitmapData.dispose();
			}
			
			updateImage(model.image);
			drawingLayer.bitmapData = new BitmapData(width, height, true, 0x00000000);
		}
		
	}
}
package photoedit.editor
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setInterval;
	
	import flight.binding.utils.BindingUtils;
	
	import mx.utils.ObjectProxy;
	
	import photoedit.view.ImageLayer;
	import photoedit.view.Layer;
	
	[Bindable]
	public class EditorDocument
	{
		public var selection:Array;
		public var model:ObjectProxy;
		
		public var toolArea:Sprite;
		public var workArea:DisplayObjectContainer;
		
		public var selectionMask:Bitmap;
		protected var selectionDisplay:Sprite;
		protected var previewMask:Bitmap;
		protected var previewDisplay:Sprite;
		protected var pattern:BitmapData;			// background pattern to draw below selection mask
		protected var patternClear:BitmapData;		// background pattern to draw below selection preview mask
		
		private var marchInterval:Number;
		private var _selectionArea:BitmapData;
		private var _selectionPreview:BitmapData;
		private var _selectionBitmap:Bitmap;
		
		public function EditorDocument(workArea:DisplayObjectContainer = null, toolArea:Sprite = null)
		{
			this.workArea = workArea;
			this.toolArea = (toolArea != null) ? toolArea : new Sprite();
			toolArea.mouseEnabled = false;
			toolArea.mouseChildren = false;
			selection = [];
			_selectionArea = null;
			
			_selectionBitmap = new Bitmap();
			selectionMask = new Bitmap();
			selectionDisplay = new Sprite();
			_selectionBitmap.cacheAsBitmap = true;
			selectionMask.cacheAsBitmap = true;
			selectionDisplay.cacheAsBitmap = true;
			
			previewMask = new Bitmap();
			previewDisplay = new Sprite();
			previewMask.cacheAsBitmap = true;
			previewDisplay.cacheAsBitmap = true;
			previewDisplay.blendMode = BlendMode.INVERT;
			
			pattern = new BitmapData(8, 8, false, 0xFFFFFF);
			patternClear = new BitmapData(8, 8, true, 0x00000000);
			fillPattern(pattern);
			fillPattern(patternClear);
			marchInterval = setInterval(marchAnts, 60);
			
			BindingUtils.bindSetter(this, selectionUpdate, this, "selection");
			BindingUtils.bindSetter(this, updateModelSelection, this, ["model", "selection", "selectionArea"]);
		}
		
		private function fillPattern(pattern:BitmapData):void
		{
			pattern.fillRect(new Rectangle(0, 4, 1, 4), 0xFF000000);
			pattern.fillRect(new Rectangle(1, 3, 1, 4), 0xFF000000);
			pattern.fillRect(new Rectangle(2, 2, 1, 4), 0xFF000000);
			pattern.fillRect(new Rectangle(3, 1, 1, 4), 0xFF000000);
			pattern.fillRect(new Rectangle(4, 0, 1, 4), 0xFF000000);
			pattern.fillRect(new Rectangle(5, 0, 1, 3), 0xFF000000);
			pattern.fillRect(new Rectangle(5, 7, 1, 1), 0xFF000000);
			pattern.fillRect(new Rectangle(6, 0, 1, 2), 0xFF000000);
			pattern.fillRect(new Rectangle(6, 6, 1, 2), 0xFF000000);
			pattern.fillRect(new Rectangle(7, 0, 1, 1), 0xFF000000);
			pattern.fillRect(new Rectangle(7, 5, 1, 3), 0xFF000000);
		}
		
		public function get selectionPreview():BitmapData
		{
			return _selectionPreview;
		}
		public function set selectionPreview(value:BitmapData):void
		{
			clearPreview();
			
			_selectionPreview = value;
			
			if(_selectionPreview == null)
				return;
			
			previewDisplay.graphics.clear();
			previewDisplay.graphics.beginBitmapFill(patternClear);
			previewDisplay.graphics.drawRect(0, 0, workArea.width, workArea.height);
			toolArea.addChildAt(previewDisplay, 0);
			
			previewMask.bitmapData = new BitmapData(_selectionPreview.width, _selectionPreview.height, true, 0x00000000);
			previewMask.bitmapData.threshold(_selectionPreview, _selectionPreview.rect, new Point(), ">", 0x80000000, 0xFF000000, 0xFF000000, false);
			previewMask.filters = [new GlowFilter(0xFF0000, 1, 2, 2, 3, 1, true, true)];
			toolArea.addChild(previewMask);
			previewDisplay.mask = previewMask;
		}
		
		public function get selectionArea():BitmapData
		{
			return _selectionArea;
		}
		public function set selectionArea(value:BitmapData):void
		{
			if(_selectionArea != null)
			{
				toolArea.removeChild(selectionMask);
				toolArea.removeChild(selectionDisplay);
				_selectionArea.dispose();
				selectionMask.bitmapData.dispose();
			}
			
			_selectionArea = value;
			selectionUpdate(selection);
			model.selection.selectionArea = _selectionArea;
			
			if(_selectionArea == null)
				return;
			
			_selectionBitmap.bitmapData = _selectionArea;
			
			selectionDisplay.graphics.clear();
			selectionDisplay.graphics.beginBitmapFill(pattern);
			selectionDisplay.graphics.drawRect(0, 0, workArea.width, workArea.height);
			toolArea.addChildAt(selectionDisplay, 0);
			
			selectionMask.bitmapData = new BitmapData(_selectionArea.width, _selectionArea.height, true, 0x00000000);
			selectionMask.bitmapData.threshold(_selectionArea, _selectionArea.rect, new Point(), ">", 0x80000000, 0xFF000000, 0xFF000000, false);
			selectionMask.filters = [new GlowFilter(0xFF0000, 1, 2, 2, 3, 1, true, true)];
			toolArea.addChild(selectionMask);
			selectionDisplay.mask = selectionMask;
		}
		
		public function get selectionBitmap():Bitmap
		{
			return _selectionBitmap;
		}
		
		public function clearPreview():void
		{
			if(_selectionPreview == null)
				return;
			toolArea.removeChild(previewMask);
			toolArea.removeChild(previewDisplay);
			_selectionPreview.dispose();
			previewMask.bitmapData.dispose();
			_selectionPreview = null;
		}
		
		public function commitPreview(mouseEvent:MouseEvent, feather:uint = 0):void
		{
			if(_selectionPreview == null)
				return;
			
			if(feather != 0)
			{
				var featheredSelection:BitmapData = new BitmapData(_selectionPreview.width+feather*2,
							_selectionPreview.height+feather*2, true, 0x00000000);
				featheredSelection.applyFilter(_selectionPreview, _selectionPreview.rect, new Point(), new BlurFilter(feather*2, feather*2, 2));
				_selectionPreview.dispose();
				_selectionPreview = featheredSelection;
			}
			
			var rect:Rectangle;
			var combined:BitmapData;
			if(_selectionArea == null)
				selectionArea = _selectionPreview.clone();
			else if(mouseEvent.altKey && mouseEvent.shiftKey)			// multiply
			{
				rect = _selectionPreview.rect.union(_selectionArea.rect);
				combined = new BitmapData(rect.width, rect.height, true, 0x00000000);
				combined.copyPixels(_selectionArea, _selectionArea.rect, new Point(), _selectionPreview);
				selectionArea = combined;
			}
			else if(mouseEvent.altKey)								// minus
			{
				rect = _selectionPreview.rect.union(_selectionArea.rect);
				combined = new BitmapData(rect.width, rect.height, true, 0x00000000);
				
				var negative:BitmapData = combined.clone();
				negative.copyPixels(_selectionPreview, _selectionPreview.rect, new Point());
				var matrix:Array =			// flip red and alpha by multiplying value by -1 and adding 255
				[-1,0,0,0,0xFF,
				0,0,0,0,0,
				0,0,0,0,0,
				0,0,0,-1,0xFF];
				negative.applyFilter(negative, negative.rect, new Point(), new ColorMatrixFilter(matrix));
				combined.copyPixels(_selectionArea, _selectionArea.rect, new Point(), negative);
				
				selectionArea = combined;
			}
			else if(mouseEvent.shiftKey)							// add				
			{
				rect = _selectionPreview.rect.union(_selectionArea.rect);
				combined = new BitmapData(rect.width, rect.height, true, 0x00000000);
				combined.copyPixels(_selectionArea, _selectionArea.rect, new Point());
				combined.copyPixels(_selectionPreview, _selectionPreview.rect, new Point(), null, null, true);
				selectionArea = combined;
			}
			else													// replace
				selectionArea = _selectionPreview.clone();
			
			clearPreview();
		}
		
		private function selectionUpdate(selection:Array):void
		{
			for each(var layer:Layer in selection)
			{
				if(layer is ImageLayer)
					ImageLayer(layer).selectionArea = _selectionArea;
			}
		}
		
		private function updateModelSelection(selection:Object):void
		{
			if(selection is BitmapData)
				selectionArea = selection as BitmapData;
		}
		
		private function marchAnts():void
		{
			var display:Sprite;
			if(previewDisplay.parent == toolArea)
				display = previewDisplay;
			else if(selectionDisplay.parent == toolArea)
				display = selectionDisplay;
			else
				return;
			
			if(display.x == 0)
				display.x = display.y = -pattern.width;
			else
				display.x = display.y += 1;
		}
		
	}
}

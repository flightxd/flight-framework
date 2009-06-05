package photoedit.editor
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	
	public class Brush
	{
		public var diameter:uint = 19;					// 1 - 2500
		public var hardness:Number = 100;				// was 0 - 1    now 0 - 100
		public var mode:String = "normal";
		public var opacity:Number = 100;				// was 0.01 - 1 now 1 - 100
		public var flow:Number = 100;					// was 0.01 - 1 now 1 - 100
		public var airbrush:Boolean = false;
		
		public var customShape:Bitmap;
		public var defaultSize:uint;
		
		public function Brush()
		{
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

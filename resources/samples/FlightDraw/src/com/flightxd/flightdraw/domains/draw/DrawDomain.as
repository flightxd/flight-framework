package com.flightxd.flightdraw.domains.draw
{
	import com.flightxd.flightdraw.domains.draw.commands.Draw;
	import com.flightxd.flightdraw.domains.draw.commands.Erase;
	import com.flightxd.flightdraw.domains.draw.commands.UpdateDocument;
	import com.flightxd.flightdraw.domains.draw.view.Document;
	
	import flash.display.BitmapData;
	
	import flight.domain.HistoryController;
	
	[Bindable]
	public class DrawDomain extends HistoryController
	{
		public static const DRAW:String = "draw";
		public static const ERASE:String = "erase";
		public static const UPDATE_DOCUMENT:String = "updateDocument";
		
		public var document:Document;
		
		override protected function init():void
		{
			addCommand(DRAW, Draw);
			addCommand(ERASE, Erase);
			addCommand(UPDATE_DOCUMENT, UpdateDocument);
		}
		
		/**
		 * Adds pixels do the document drawing.
		 */
		public function draw(bitmapData:BitmapData):Object
		{
			return execute(DRAW, arguments);
		}
		
		/**
		 * Erases pixels from the document drawing.
		 */
		public function erase(bitmapData:BitmapData):Object
		{
			return execute(ERASE, arguments);
		}
		
		/**
		 * Updates the current document or creates a new one if there is no document.
		 */
		public function updateDocument(title:String, width:Number, height:Number):Object
		{
			return execute(UPDATE_DOCUMENT, arguments);
		}
		
		
	}
}
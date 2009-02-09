package com.flightxd.flightdraw.domains.draw
{
	import com.flightxd.flightdraw.domains.draw.commands.Draw;
	import com.flightxd.flightdraw.domains.draw.commands.Erase;
	import com.flightxd.flightdraw.domains.draw.commands.UpdateDocument;
	
	import flash.display.BitmapData;
	
	import flight.domain.HistoryController;
	import flight.utils.Registry;

	public class Controller extends HistoryController
	{
		public static const DRAW:String = "draw";
		public static const ERASE:String = "erase";
		public static const UPDATE_DOCUMENT:String = "updateDocument";
		
		// all of the rest of the DomainController/HistoryController data is already
		// a global single instance, so the model is the last element that needs to
		// populated via a single global access
		[Bindable]
		public var model:Model = Registry.getInstance(Model) as Model;
		
		override protected function init():void
		{
			addCommand(DRAW, Draw);
			addCommand(ERASE, Erase);
			addCommand(UPDATE_DOCUMENT, UpdateDocument);
		}
		
		/**
		 * Adds pixels do the document drawing.
		 */
		public function draw(bitmapData:BitmapData):Boolean
		{
			return execute(DRAW, arguments);
		}
		
		/**
		 * Erases pixels from the document drawing.
		 */
		public function erase(bitmapData:BitmapData):Boolean
		{
			return execute(ERASE, arguments);
		}
		
		/**
		 * Updates the current document or creates a new one if there is no document.
		 */
		public function updateDocument(title:String, width:Number, height:Number):Boolean
		{
			return execute(UPDATE_DOCUMENT, arguments);
		}
		
		
	}
}
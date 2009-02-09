package com.flightxd.flightdraw.domains.draw.model
{
	import flash.display.Bitmap;
	
	import flight.vo.ValueObject;
	
	[Bindable]
	public class Document extends ValueObject
	{
		
		public var title:String;
		
		public var width:Number;
		public var height:Number;
		
		public var drawing:Bitmap;
	}
}
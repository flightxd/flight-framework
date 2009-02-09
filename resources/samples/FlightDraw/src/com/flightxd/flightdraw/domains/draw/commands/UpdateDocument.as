package com.flightxd.flightdraw.domains.draw.commands
{
	import com.flightxd.flightdraw.domains.draw.Controller;
	import com.flightxd.flightdraw.domains.draw.model.Document;
	
	import flight.commands.ICommand;
	
	public class UpdateDocument implements ICommand
	{
		public var client:Controller;
		
		[Arguments(0)] public var title:String;
		[Arguments(1)] public var width:Number;
		[Arguments(2)] public var height:Number;
		
		public function execute():Boolean
		{
			if(client.model.document == null) {
				client.model.document = new Document();
			}
			
			client.model.document.title = title;
			client.model.document.width = width;
			client.model.document.height = height;
			
			return true;
		}
		
	}
}
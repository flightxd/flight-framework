/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.commands
{
	import flight.utils.ValueObject;
	import flight.utils.getType;
	
	import mx.core.IMXMLObject;
	
	public class Command extends ValueObject implements ICommand, IMXMLObject
	{
		
		public function execute():void
		{
		}
		
		public function initialized(document:Object, id:String):void
		{
			if ("addCommand" in document) {
				document["addCommand"](id, getType(this));
			}
		}
		
	}
}

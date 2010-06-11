/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.config
{
	import flash.external.ExternalInterface;
	import flash.net.URLVariables;
	
	dynamic public class URLConfig extends Config
	{
		
		override protected function init():void
		{
			if ( !ExternalInterface.available ) {
				return;
			}
			
			var queryString:String = ExternalInterface.call("eval", "location.search");
			if (queryString.length > 0) {
				formatProperties( new URLVariables(queryString.substr(1)) );	// remove the '?' from the search string
			}
		}
		
	}
}
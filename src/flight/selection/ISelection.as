/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.selection
{
	import flight.list.IList;
	
	public interface ISelection
	{
		function get item():Object;
		function set item(value:Object):void;
		
		function get multiselect():Boolean;
		function set multiselect(value:Boolean):void;
		
		function get items():IList;
		
		function select(items:*):void;
		
	}
}

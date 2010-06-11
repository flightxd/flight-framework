/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.selection
{
	import flight.list.IList;
	
	public interface IListSelection extends ISelection
	{
		function get index():int;
		function set index(value:int):void;
		
		function get indices():IList;
	}
}

/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.position
{
	public interface IPlayer extends IProgress
	{
		function play():void
		function pause():void;
		function stop():void;
		
		function seek(position:Number = 0):void;
	}
}
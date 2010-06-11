/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.position
{
	public interface IPosition extends IProgress
	{
		function get filled():Boolean;
		
		function get min():Number;
		function set min(value:Number):void;
		
		function get max():Number;
		function set max(value:Number):void;
		
		function get space():Number;
		function set space(value:Number):void;
		
		function get stepSize():Number;
		function set stepSize(value:Number):void;
		
		function get skipSize():Number;
		function set skipSize(value:Number):void;
		
		function forward():void;
		function backward():void;
		
		function skipForward():void;
		function skipBackward():void;
		
		
	}
}

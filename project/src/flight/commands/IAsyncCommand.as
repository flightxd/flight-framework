/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.commands
{
	import flash.events.IEventDispatcher;
	
	import flight.net.IResponse;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="cancel", type="flash.events.Event")]
	
	public interface IAsyncCommand extends IEventDispatcher, ICommand
	{
		function get response():IResponse;
	}
}

/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.view
{
	import mx.core.IMXMLObject;
	
	/**
	 * MXML utility class used to map a mediator to a view.
	 */
	public class Mapping implements IMXMLObject
	{
		/**
		 * The mediator class
		 */
		public var mediator:Class;
		
		/**
		 * The view class
		 */
		public var view:Class;
		
		/**
		 * Take and map the mediator to the view, then destroy this object
		 */
		public function initialized(document:Object, id:String):void
		{
			var map:MediatorMap = document as MediatorMap;
			if (!map || !mediator || !view) return;
			map.map(mediator, view);
			
			document[id] = null; // remove references to this object
		}
	}
}
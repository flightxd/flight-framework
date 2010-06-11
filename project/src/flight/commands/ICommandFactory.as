/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.commands
{
	/**
	 * The ICommandFactory establishes the core methods for storing and retrieving
	 * ICommand classes and their instances; based on the Factory Design Pattern.
	 * Used by plugin architectures that gain flexibility by hiding implementation.
	 */
	public interface ICommandFactory
	{
		/**
		 * Registers a command class with a unique id for later access.
		 */
		function addCommand(type:String, commandClass:Class, propertyList:Array = null):void;
		
		/**
		 * Retrieves the command class registered with this type.
		 */
		function getCommand(type:String):Class;
		
		/**
		 * Primary method responsible for command class instantiation, hiding the details
		 * of class inheritance, implementation, origin, etc. Allows instantiation parameters.
		 */
		function createCommand(type:String, properties:Object = null):ICommand;
	}
}
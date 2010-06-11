/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package flight.utils
{
	import flash.utils.ByteArray;
	
	import flight.events.Dispatcher;
	
	/**
	 * ValueObject is a convenient base class for data-rich objects that can be
	 * compared, copied and serialized. ValueObject offers a static
	 * implementation of the methods equals() and clone() for use throughout
	 * the system.
	 */
	public class ValueObject extends Dispatcher implements IValueObject
	{
		public function ValueObject()
		{
			Type.registerType(this);
		}
		
		/**
		 * Evaluates the equality of another object of the same type, based on
		 * its properties.
		 * 
		 * @param	value			The target of the comparison.
		 */
		public function equals(value:Object):Boolean
		{
			return ValueObject.equals(this, value);
		}
		
		/**
		 * Returns a new object that is an exact copy of this object.
		 * 
		 * @return					The replicated object.
		 */
		public function clone():Object
		{
			return ValueObject.clone(this);
		}
		
		// ========== Static Methods ========== //
		
		/**
		 * Evaluates the equality of two objects of the same type, based on
		 * their properties. This method uses ActionScript's serialization
		 * methods for string comparison and provides a deep comparison
		 * (matching values on the entire structure). This method is not as
		 * fast as most custom implementations.
		 * 
		 * @param	value1			The first target of the comparison.
		 * @param	value1			The second target of the comparison.
		 * 
		 * @see		flash.utils.ByteArray#writeObject
		 */
		public static function equals(value1:Object, value2:Object):Boolean
		{
			if (value1 == value2) {
				return true;
			}
			
			Type.registerType(value1);
			
			var so1:ByteArray = new ByteArray();
	       	so1.writeObject(value1);
	        
			var so2:ByteArray = new ByteArray();
        	so2.writeObject(value2);
			
			return Boolean(so1.toString() == so2.toString());
		}
		
		/**
		 * Returns a new object that is an exact copy of the target object. This
		 * method uses ActionScript's serialization methods to provide a deep
		 * copy (replication of the entire structure). This method is not as
		 * fast as most custom implementations.
		 * 
		 * @param	value			The target object to copy.
		 * @return					The replicated object.
		 * 
		 * @see		flash.utils.ByteArray#writeObject
		 * @see		flash.utils.ByteArray#readObject
		 */
		public static function clone(value:Object):Object
		{
			Type.registerType(value);
			
			var so:ByteArray = new ByteArray();
	        so.writeObject(value);
	        
	        so.position = 0;
	        return so.readObject();
		}
		
	}
}
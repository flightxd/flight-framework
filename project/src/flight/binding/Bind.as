package flight.binding
{
	
	public class Bind
	{
		
		/**
		 * 
		 */
		public static function addBinding(target:Object, targetPath:String, source:Object, sourcePath:String, twoWay:Boolean = false):Boolean
		{
			var binding:Binding = Binding.getBinding(source, sourcePath);
			
			var success:Boolean;
			if(twoWay || targetPath.split(".").length > 1) {
				var binding2:Binding = Binding.getBinding(target, targetPath);
				
				success = binding.bind(binding2, "value");
				if(twoWay) {
					binding2.bind(binding, "value");
				} else {
					binding2.applyOnly = true;
				}
			} else {
				success = binding.bind(target, targetPath);
			}
			return success;
		}
		
		/**
		 * 
		 */
		public static function removeBinding(target:Object, targetPath:String, source:Object, sourcePath:String):Boolean
		{
			var binding:Binding = Binding.getBinding(source, sourcePath);
			var success:Boolean = binding.unbind(target, targetPath);
			
			if(!success) {
				var binding2:Binding = Binding.getBinding(target, targetPath);
				
				success = binding.unbind(binding2, "value");
				binding2.unbind(binding, "value");
				if( !binding2.hasBinds() ) {
					Binding.releaseBinding(binding2);
				}
			}
			
			if( !binding.hasBinds() ) {
				Binding.releaseBinding(binding);
			}
			return success;
		}
		
		/**
		 * 
		 */
		public static function addListener(listener:Function, source:Object, sourcePath:String):void
		{
			var binding:Binding = Binding.getBinding(source, sourcePath);
			binding.bindListener(listener);
		}
		
		/**
		 * 
		 */
		public static function removeListener(listener:Function, source:Object, sourcePath:String):void
		{
			var binding:Binding = Binding.getBinding(source, sourcePath);
			binding.unbindListener(listener);
			if( !binding.hasBinds() ) {
				Binding.releaseBinding(binding);
			}
		}
		
	}
}

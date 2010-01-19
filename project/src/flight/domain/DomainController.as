package flight.domain
{
	import flash.display.DisplayObject;
	
	import flight.commands.ICommand;
	import flight.injection.IInjectorSubject;
	import flight.injection.Injector;
	
	import mx.core.IMXMLObject;
	
	public class DomainController extends CommandController implements IMXMLObject, IInjectorSubject
	{
		public var context:DisplayObject;
		
		/**
		 * 
		 */
		public function DomainController(context:DisplayObject = null)
		{
			if (context) initialized(context, null);
		}
		
		/**
		 * Called after a singleton has been created and instantiated and all
		 * class properties specified on the MXML tag have been initialized.
		 * 
		 * @param	document			The MXML document that created this
		 * 								DomainController object.
		 * @param	id					The identifier used by the MXML document
		 * 								to refer to this object.
		 */
		public function initialized(document:Object, id:String):void
		{
			context = document as DisplayObject;
			if (context) {
				// register this domain controller as an injection
				Injector.provideInjection(this, context);
				Injector.inject(this, context);
			}
		}
		
		
		public function injected():void
		{
			init();
		}
		
		
		override public function createCommand(type:String, properties:Object=null):ICommand
		{
			var command:ICommand = super.createCommand(type, properties);
			
			if (context) {
				// inject into commands anything needed
				Injector.inject(command, context);
			}
			
			return command;
		}
		
		/**
		 * The init() method is called upon the initial construction of a
		 * DomainController object, but only for the first instance created.
		 * Subsequent instances are discareded, and so should be minimal in
		 * their construction. The init() method should be overridden and
		 * implement all of an object's initialization. A classes constructor
		 * should remain empty.
		 */
		protected function init():void
		{
		}
		
	}
}
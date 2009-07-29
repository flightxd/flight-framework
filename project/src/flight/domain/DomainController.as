package flight.domain
{
	import flight.commands.CommandController;
	import flight.utils.Registry;
	import flight.utils.Singleton;
	import flight.utils.getType;
	
	import mx.core.IMXMLObject;
	
	public class DomainController extends CommandController implements IMXMLObject
	{
		
		/**
		 * DomainController should only be instantiated internally or via MXML where
		 * it will be replaced (and only if it is assigned an 'id').
		 * ActionScript access should be through a static getIntance().
		 */
		public function DomainController()
		{
			var type:Class = getType(this);
			if (Registry.lookup(type) == null) {
				Registry.register(type, this);
				init();
			}
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
			if (id == null) {
//				trace("Warning: DomainController " + getClassName(this) + " 'id' is undefined in " +
//								getClassName(document) + ". MXML-instantiated singletons require an id.");
			} else {
				var type:Class = getType(this);
				document[id] = Singleton.getInstance(type);
			}
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
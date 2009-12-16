package
{
	import assets.ChatView;
	
	import com.flightxd.hellounion.config.UnionConfig;
	import com.flightxd.hellounion.domains.union.UnionController;
	import com.flightxd.hellounion.domains.union.UnionMap;
	import com.flightxd.hellounion.services.UnionServices;
	
	import flash.display.Sprite;

	/**
	 * @author John Lindquist
	 */
	[SWF(width="550", height="400", frameRate="31", backgroundColor="#ffffff")]
	public class Main extends Sprite
	{
		public function Main()
		{
			new UnionConfig(this);
			new UnionMap(this);
			new UnionServices(this);
			new UnionController(this);
			addChild(new ChatView());
		}
	}
}
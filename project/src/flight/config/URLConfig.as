package flight.config
{
	import flash.external.ExternalInterface;
	import flash.net.URLVariables;
	
	public class URLConfig extends Config
	{
		public function URLConfig()
		{
			if(!ExternalInterface.available)
				return;
			var queryString:String = ExternalInterface.call("eval", "location.search");
			if(queryString.length > 0)
				configData = new URLVariables(queryString.substr(1));	// remove the '?' from the search string
		}
		
	}
}
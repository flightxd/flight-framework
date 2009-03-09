package flight.services.handlers
{
	import flash.net.URLLoader;
	import flash.utils.IDataInput;
	
	public class FormatHandlers
	{
		
		/**
		 * Provided URLLoader formatter which accepts the URLLoader and
		 * returns its data. Use this as the first result handler of a call
		 * with URLLoader.
		 */
		public function urlLoaderToData(loader:URLLoader):Object
		{
			return loader.data;
		}
		
		/**
		 * Provided IDataInput formatter which accepts a IDataInput and
		 * returns its bytes as text. Use this as the first result handler of a
		 * call with URLStream if all you want is the text input.
		 */
		public function dataInputToText(data:IDataInput):String
		{
			return data.readUTFBytes(data.bytesAvailable);
		}
		
		/**
		 * Provided IDataInput formatter which accepts a IDataInput and
		 * returns its bytes as an object. This can be used to convert
		 * serialized AMF into ActionScript objects.
		 */
		public function dataInputToData(data:IDataInput):Object
		{
			return data.readObject();
		}
		
		/**
		 * Provided formatter to convert text to XML.
		 */
		public function textToXML(text:String):XML
		{
			return XML(text);
		}
		
		/**
		 * Provided formatter to convert JSON text to an object.
		 */
		public function jsonToData(json:String):Object
		{
			return JSON.decode(json);
		}

	}
}
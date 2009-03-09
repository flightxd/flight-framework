package flight.filesystem
{
	import flash.desktop.Icon;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import flight.net.IResponse;
	import flight.net.Response;
	
	public class AsyncFile extends EventDispatcher
	{
		public static function get applicationDirectory():AsyncFile
		{
			return new AsyncFile(File.applicationDirectory.nativePath);
		}
		
		public static function get applicationStorageDirectory():AsyncFile
		{
			return new AsyncFile(File.applicationStorageDirectory.nativePath);
		}
		
		public static function get desktopDirectory():AsyncFile
		{
			return new AsyncFile(File.desktopDirectory.nativePath);
		}
		
		public static function get documentsDirectory():AsyncFile
		{
			return new AsyncFile(File.documentsDirectory.nativePath);
		}
		
		public static function get userDirectory():AsyncFile
		{
			return new AsyncFile(File.userDirectory.nativePath);
		}
		
		public static function createTempDirectory():AsyncFile
		{
			return new AsyncFile(File.createTempDirectory().nativePath);
		}
		
		public static function createTempFile():AsyncFile
		{
			return new AsyncFile(File.createTempFile().nativePath);
		}
		
		public static function getRootDirectories():Array
		{
			return File.getRootDirectories().map(toAsyncFile);
		}
		
		
		
		protected var _file:File;
		protected var _stream:FileStream;
		
		public function AsyncFile(path:String = null)
		{
			_file = new File(path);
		}
		
		public function get file():File
		{
			return _file;
		}
		
		public function get stream():FileStream
		{
			return _stream;
		}
		
		public function get exists():Boolean
		{
			return file.exists;
		}
		
		public function get icon():Icon
		{
			return file.icon;
		}
		
		public function get isDirectory():Boolean
		{
			return file.isDirectory;
		}
		
		public function isHidden():Boolean
		{
			return file.isHidden;
		}
		
		public function isOpen():Boolean
		{
			return stream != null;
		}
		
		public function isPackage():Boolean
		{
			return file.isPackage;
		}
		
		public function isSymbolicLink():Boolean
		{
			return file.isSymbolicLink;
		}
		
		[Bindable("nativePathChange")]
		public function get nativePath():String
		{
			return file.nativePath;
		}
		
		public function set nativePath(value:String):void
		{
			if (file.nativePath == value) {
				return;
			}
			file.nativePath = value;
			dispatchEvent(new Event("urlChange"));
			dispatchEvent(new Event("nativePathChange"));
		}
		
		public function get parent():AsyncFile
		{
			return toAsyncFile(file.parent);
		}
		
		public function get spaceAvailable():Number
		{
			return file.spaceAvailable;
		}
		
		[Bindable("nativePathChange")]
		public function get url():String
		{
			return file.url;
		}
		
		public function set url(value:String):void
		{
			if (file.url == value) {
				return;
			}
			file.url = value;
			dispatchEvent(new Event("urlChange"));
			dispatchEvent(new Event("nativePathChange"));
		}
		
		
		public function browseForDirectory(title:String):IResponse
		{
			file.browseForDirectory(title);
			return new Response(file, Event.SELECT, Event.CANCEL).addResultHandler(toAsyncFile);
		}
		
		public function browseForOpen(title:String, typeFilter:Array = null):IResponse
		{
			file.browseForOpen(title, typeFilter);
			return new Response(file, Event.SELECT, Event.CANCEL).addResultHandler(toAsyncFile);
		}
		
		public function browseForOpenMultiple(title:String, typeFilter:Array = null):IResponse
		{
			file.browseForOpenMultiple(title, typeFilter);
			var response:Response = new Response();
			response.addCompleteEvent(file, FileListEvent.SELECT_MULTIPLE, "files");
			response.addCancelEvent(file, Event.CANCEL);
			return response.addResultHandler(toFileList);
		}
		
		public function browseForSave(title:String):IResponse
		{
			file.browseForSave(title);
			return new Response(file, Event.SELECT, Event.CANCEL).addResultHandler(toAsyncFile);
		}
		
		public function cancel():void
		{
			file.cancel();
		}
		
		public function canonicalize():void
		{
			file.canonicalize();
		}
		
		public function clone():AsyncFile
		{
			return toAsyncFile(file);
		}
		
		public function copyTo(newLocation:AsyncFile, overwrite:Boolean = false):IResponse
		{
			file.copyToAsync(newLocation.file, overwrite);
			var response:Response = new Response();
			response.addCompleteEvent(_file, Event.COMPLETE);
			response.addCancelEvent(_file, SecurityErrorEvent.SECURITY_ERROR);
			response.addCancelEvent(_file, IOErrorEvent.IO_ERROR);
			return response.addResultHandler(toAsyncFile);
		}
		
		public function createDirectory():void
		{
			file.createDirectory();
		}
		
		public function deleteDirectory(deleteDirectoryContents:Boolean = false):IResponse
		{
			file.deleteDirectoryAsync(deleteDirectoryContents);
			var response:Response = new Response();
			response.addCompleteEvent(_file, Event.COMPLETE);
			response.addCancelEvent(_file, SecurityErrorEvent.SECURITY_ERROR);
			response.addCancelEvent(_file, IOErrorEvent.IO_ERROR);
			return response.addResultHandler(toAsyncFile);
		}
		
		public function deleteFile():IResponse
		{
			file.deleteFileAsync();
			var response:Response = new Response();
			response.addCompleteEvent(_file, Event.COMPLETE);
			response.addCancelEvent(_file, SecurityErrorEvent.SECURITY_ERROR);
			response.addCancelEvent(_file, IOErrorEvent.IO_ERROR);
			return response.addResultHandler(toAsyncFile);
		}
		
		public function getDirectoryListing():IResponse
		{
			file.getDirectoryListingAsync();
			
			var response:Response = new Response();
			response.addCompleteEvent(file, FileListEvent.DIRECTORY_LISTING, "files");
			response.addCancelEvent(file, IOErrorEvent.IO_ERROR);
			return response.addResultHandler(toFileList);
		}
		
		public function getRelativePath(ref:AsyncFile, useDotDot:Boolean = false):String
		{
			return file.getRelativePath(ref.file, useDotDot);
		}
		
		public function moveTo(newLocation:AsyncFile, overwrite:Boolean = false):IResponse
		{
			file.moveToAsync(newLocation.file, overwrite);
			var response:Response = new Response();
			response.addCompleteEvent(_file, Event.COMPLETE);
			response.addCancelEvent(_file, SecurityErrorEvent.SECURITY_ERROR);
			response.addCancelEvent(_file, IOErrorEvent.IO_ERROR);
			return response.addResultHandler(toAsyncFile);
		}
		
		public function moveToTrash():IResponse
		{
			file.moveToTrashAsync();
			var response:Response = new Response();
			response.addCompleteEvent(_file, Event.COMPLETE);
			response.addCancelEvent(_file, SecurityErrorEvent.SECURITY_ERROR);
			response.addCancelEvent(_file, IOErrorEvent.IO_ERROR);
			return response.addResultHandler(toAsyncFile);
		}
		
		public function resolvePath(path:String):AsyncFile
		{
			return toAsyncFile(file.resolvePath(path));
		}
		
		
		public function open(fileMode:String):IResponse
		{
			_stream = new FileStream();
			stream.openAsync(file, fileMode);
			return new Response(stream, Event.COMPLETE, IOErrorEvent.IO_ERROR).addResultHandler(toAsyncFile);
		}
		
		public function close():IResponse
		{
			stream.close();
			return new Response(stream, Event.CLOSE, IOErrorEvent.IO_ERROR).addResultHandler(toAsyncFile);
		}
		
		public function read():IResponse
		{
			var stream:FileStream = new FileStream()
			stream.openAsync(file, FileMode.READ);
			var response:Response = new Response(stream, Event.COMPLETE, IOErrorEvent.IO_ERROR);
			response.addResultHandler(toByteArray);
			return response;
		}
		
		public function write(byteArray:ByteArray):IResponse
		{
			var stream:FileStream = new FileStream()
			stream.openAsync(file, FileMode.WRITE);
			stream.writeBytes(byteArray, 0, byteArray.bytesAvailable);
			stream.close();
			var response:Response = new Response(stream, Event.CLOSE, IOErrorEvent.IO_ERROR);
			response.addResultHandler(toThis);
			return response;
		}
		
		public function readText():IResponse
		{
			var stream:FileStream = new FileStream()
			stream.openAsync(file, FileMode.READ);
			var response:Response = new Response(stream, Event.COMPLETE, IOErrorEvent.IO_ERROR);
			response.addResultHandler(toText);
			return response;
		}
		
		public function writeText(text:String):IResponse
		{
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeUTFBytes(text);
			return write(byteArray);
		}
		
		
		
		protected static function toFileList(files:Array):Array
		{
			return files.map(toAsyncFile);
		}
		
		protected static function toAsyncFile(file:File):AsyncFile
		{
			return new AsyncFile(file.nativePath);
		}
		
		protected function toByteArray(stream:FileStream):ByteArray
		{
			var byteArray:ByteArray = new ByteArray();
			stream.readBytes(byteArray, 0, stream.bytesAvailable);
			stream.close();
			return byteArray;
		}
		
		protected function toText(stream:FileStream):String
		{
			var text:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			return text;
		}
		
		protected function toThis(stream:FileStream):AsyncFile
		{
			return this;
		}
	}
}
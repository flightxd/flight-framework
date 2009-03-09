package flight.data
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLSchemaResult;
	import flash.data.SQLStatement;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.utils.flash_proxy;
	
	import flight.net.IResponse;
	import flight.net.Response;
	
	import withincode.events.DatabassEvent;
	
	use namespace flash_proxy;
	
	registerClassAlias("withincode.db.Database", Database);
	
	[Event(name="complete", type="withincode.events.DatabassEvent")]
	
	public class Database implements IExternalizable
	{
		public static const ASYNCHRONOUS:String = "asynchronous";
		
		protected static var cache:Object = {};
		
		protected var runLaters:Array = [];
		
		protected var _connectionName:String = "";
		protected var _file:File;
		protected var _conn:SQLConnection;
		protected var eventDispatcher:EventDispatcher;
		
		protected var currentQueries:Dictionary = new Dictionary();
		protected var currentQueriesSuccess:Boolean = true;
		
		/**
		 * Constructor, may be passed in a connection name which will store a database file in the user's account
		 * by the file name connectionName.db or optionally a file may be passed in which references an existing
		 * database file.
		 */
		public function Database(connectionName:String = "main")
		{
			if (connectionName is String) {
				_connectionName = connectionName;
			}
		}
		
		
		public function get connectionName():String
		{
			return _connectionName;
		}
		
		public function get file():File
		{
			return _file;
		}
		
		
		public function analyze(resourceName:String = null):IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase);
			
			return run(connection.analyze, resourceName, response.createResponder(), response);
		}
		
		public function attach(name:String, reference:Object = null, encryptionKey:ByteArray = null):IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase);
			
			return run(connection.attach, name, reference, response.createResponder(), encryptionKey, response);
		}
		
		public function begin(transactionLockType:String = null):IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase);
			
			return run(connection.begin, transactionLockType, response.createResponder(), response);
		}
		
		public function cancel():IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase);
			
			return run(connection.cancel, response.createResponder(), response);
		}
		
		public function close():IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase);
			
			return run(connection.close, response.createResponder(), response);
		}
		
		public function commit():IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase);
			
			return run(connection.commit, response.createResponder(), response);
		}
		
		public function compact():IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase);
			
			return run(connection.compact, response.createResponder(), response);
		}
		
		public function deanalyze():IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase);
			
			return run(connection.deanalyze, response.createResponder(), response);
		}
		
		public function detach(name:String):IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase);
			
			return run(connection.detach, name, response.createResponder(), response);
		}
		
		public function loadSchema(type:Class = null, name:String = null, database:String = "main", includeColumnSchema:Boolean = true):IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase).addResultHandler(toSchema);
			
			return run(connection.loadSchema, type, name, database, includeColumnSchema, response.createResponder(), response);
		}
		
		public function open(reference:File = null, openMode:String = "create", autoCompact:Boolean = false, pageSize:int = 1024, encryptionKey:ByteArray = null):IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase);
			
			_file = reference;
			_conn = new SQLConnection();
			_conn.openAsync(reference, openMode, response.createResponder(), autoCompact, pageSize, encryptionKey);
			cache[_connectionName] = {connection: _conn, file: _file};
			
			return response;
		}
		
		public function reencrypt(newEncryptionKey:ByteArray):IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase);
			
			return run(connection.reencrypt, newEncryptionKey, response.createResponder(), response);
		}
		
		public function rollback():IResponse
		{
			var response:Response = new Response();
			response.addResultHandler(toDatabase);
			
			return run(connection.rollback, response.createResponder(), response);
		}
		
		
		/**
		 * Queries the database. May return an array of row objects or a number of rows affected
		 * or the new id inserted into the database, depending if it was a SELECT, UPDATE/DELETE,
		 * or INSERT query.
		 */
		public function query(sql:String, ...params):IResponse
		{
			return queryWithClass(sql, null, params);
		}
		
		
		/**
		 * SELECTs from database and populates the results into objects of type classs.
		 */
		public function queryWithClass(sql:String, classs:Class = null, ...params):IResponse
		{
			var stmt:SQLStatement = prepareStatement(sql, params);
			stmt.itemClass = classs;
			var response:Response = new Response(stmt, SQLEvent.RESULT, SQLErrorEvent.ERROR);
			response.addResultHandler(onQueryComplete);
			
			return run(stmt.execute, response);
		}
		
		
		
		
		
		/**
		 * Prepares a statement for exectuing a query.
		 */
		public function prepareStatement(sql:String, ...params:Array):SQLStatement
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = connection;
			stmt.text = sql;
			
			params = getInnermostArray(params);
			
			for (var i:int = 0; i < params.length; i++) {
				stmt.parameters[i] = params[i];
			}
			
			return stmt;
		}
		
		
		/**
		 * Public read-only accessor to the connection
		 */
		public function get connection():SQLConnection
		{
			if (!_conn) {
				makeConnection();
			}
			return _conn;
		}
		
		
		protected function run(method:Function, ...params:Array):IResponse
		{
			if (!connection.connected) {
				params.unshift(method);
				return runLater(params);
			}
			
			var response:IResponse = params.pop();
			method.apply(null, params);
			return response;
		}
		
		protected function runLater(params:Array):IResponse
		{
			runLaters.push(params);
			
			return params[params.length - 1];
		}
		
		/**
		 * Returns a connection by the registered alias and with the appropriate synchronisation. This provides
		 * a cache for the connection objects to be used. The main.db database is preregistered under the alias
		 * "main", so a call to getConnection with no parameters will return the default application database.
		 */
		protected function makeConnection():void
		{
			var key:String = _connectionName;
			
			if (_connectionName in cache) {
				var data:Object = cache[_connectionName];
				_conn = data.connection;
				_file = data.file;
				if (!_conn.connected) {
					(new Response(_conn, SQLEvent.OPEN)).addResultHandler(onOpen);
				}
			} else {
				if (_connectionName) {
					var file:File = File.applicationStorageDirectory.resolvePath(_connectionName + ".db");
				}
				
				open(file).addResultHandler(onOpen);
			}
		}
		
		protected function onOpen(database:Database):void
		{
			for each (var params:Array in runLaters) {
				run.apply(null, params);
			}
		}
		
		protected function toDatabase(data:Object):Database
		{
			return this;
		}
		
		protected function toSchema(database:Database):SQLSchemaResult
		{
			return database.connection.getSchemaResult();
		}
		
		protected function onQueryComplete(stmt:SQLStatement):*
		{
			return getResult(stmt);
		}
		
		protected function getResult(stmt:SQLStatement):*
		{
			var result:SQLResult = stmt.getResult();
			
			if (result.data) {
				return result.data;
			} else if (result.lastInsertRowID) {
				return result.lastInsertRowID;
			} else {
				return result.rowsAffected;
			}
		}
		
		protected function getInnermostArray(params:Array):Array
		{
			if (params.length == 1 && params[0] is Array)
				return getInnermostArray(params[0]);
			else
				return params;
		}
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeUTF(_connectionName);
			output.writeUTF(_file ? _file.nativePath : null);
		}
		
		public function readExternal(input:IDataInput):void
		{
			_connectionName = input.readUTF();
			var fileName:String = input.readUTF();
			if (fileName)
				_file = new File(fileName);
		}
	}
}
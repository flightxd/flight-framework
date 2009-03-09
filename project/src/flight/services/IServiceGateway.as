package flight.services
{
	import flight.services.handlers.IResponseHandler;
	
	import mx.rpc.IResponder;
	
	public interface IServiceGateway
	{
		
		function saveItem(item:Object):IResponseHandler;
		
		function loadItem(id:Object):IResponseHandler;
		
		function deleteItem(id:Object):IResponder;
		
		
	}
}
package flight.domain
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import flight.commands.IAsyncCommand;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="cancel", type="flash.events.Event")]
	
	/**
	 * An abstract command class that supports Asynchronous commands through dispatching
	 * the ExecutionComplete event upon completion of the asynchronous action.
	 */
	public class AsyncCommand extends EventDispatcher implements IAsyncCommand
	{
		public function AsyncCommand()
		{
			
		}
		
		/**
		 * The execute method should be overridden
		 */
		public function execute():Boolean
		{
			return false;
		}
		
		/**
		 * To be called when the Asynchronous action has been completed.
		 */
		protected function dispatchComplete(event:Event = null):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * To be called if the Asynchronous action has been canceled.
		 */
		protected function dispatchCancel(event:Event = null):void
		{
			dispatchEvent(new Event(Event.CANCEL));
		}
		
	}
}
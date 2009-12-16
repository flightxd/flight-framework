package com.flightxd.hellounion.view
{
	import assets.ChatView;
	
	import com.flightxd.hellounion.domains.union.UnionController;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import flight.binding.Bind;
	import flight.events.ListEvent;
	import flight.events.ListEventKind;
	import flight.events.PropertyEvent;
	import flight.injection.IInjectorSubject;
	import flight.net.IResponse;
	
	import net.user1.reactor.Client;

	/**
	 * @author John Lindquist
	 */
	public class ChatViewMediator implements IInjectorSubject
	{

		[Inject]
		public var controller:UnionController;

		[Inject]
		public var view:ChatView;

		public function injected():void
		{
			//text
			view.chatDisplay.htmlText = "<font size='16pt'><b>Welcome to Flying Robot Pants Chat!</b></font>";
			view.userList.htmlText = "<font size='16pt'><b>User List</b></font>";
			view.inputDisplay.text = "Type a message then press enter...";
			//bindings
			Bind.addBinding(view, "statusDisplay.text", controller, "connectionStatus");
			Bind.addListener(connectionChanged, controller, "isConnected");
			Bind.addListener(clientsChanged, controller, "clients");
			//listeners
			view.connectButton.addEventListener(MouseEvent.CLICK, connectButton_clickHandler);
			view.inputDisplay.addEventListener(FocusEvent.FOCUS_IN, inputDisplay_focusInHandler);
			view.inputDisplay.addEventListener(KeyboardEvent.KEY_DOWN, inputDisplay_keyDownHandler);
			
			controller.messages.addEventListener(ListEvent.LIST_CHANGE, messagesChanged);
		}
		
		protected function messagesChanged(event:ListEvent):void
		{
			if (event.kind == ListEventKind.ADD && event.location1 == controller.messages.length - 1) {
				var message:String = "<font size='12pt'>" + event.items.pop() + "</font>";
				view.chatDisplay.htmlText += message;
			}
		}

		protected function clientsChanged(event:PropertyEvent):void
		{
			var clients:Array = event.newValue as Array;
			view.userList.htmlText = "<font size='16pt'><b>User List</b></font>";
			for each (var client:Client in clients)
			{
				view.userList.htmlText += "Guest " + client.getClientID();
			}
		}

		protected function connectButton_clickHandler(event:Event):void
		{
			var finishedConnectingResponse:IResponse = controller.connect();
			finishedConnectingResponse.addResultHandler(connectedHandler);
		}

		protected function connectionChanged(event:PropertyEvent):void
		{
			var isConnected:Boolean = event.newValue as Boolean;
			if (isConnected)
			{
				view.inputDisplay.selectable = true;
				view.statusIndicator.gotoAndStop("connected");
				view.connectButton.label = "Connected";
				view.connectButton.enabled = false;
			}
			else
			{
				view.inputDisplay.selectable = false;
				view.statusIndicator.gotoAndStop("disconnected");
				view.connectButton.label = "Connect";
				view.connectButton.enabled = true;
			}
		}

		protected function inputDisplay_focusInHandler(event:FocusEvent):void
		{
			clearInput();
		}

		protected function inputDisplay_keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ENTER)
			{
				controller.sendMessage(view.inputDisplay.text);
				clearInput();
			}
		}

		private function clearInput():void
		{
			view.inputDisplay.text = "";
		}

		private function connectedHandler(data:*):void
		{
			//Look at me, I'm in the Mediator after all the connection logic is done! Amazing!"
		}
	}
}
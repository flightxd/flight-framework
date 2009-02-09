package com.flightxd.flightdraw.domains.state
{
	import com.flightxd.flightdraw.domains.state.model.Phase;
	
	import flight.domain.DomainController;
	import flight.utils.Registry;
	
	/**
	 * A domain can encapsulate the logic of any system - in this case, the
	 * presentation state. This DomainController deals directly with application
	 * flow and stores view state on the model. NOTE: The controller and model
	 * do not know about specific view components but encapsulate the state as
	 * data components can bind to.
	 */
	public class Controller extends DomainController
	{
		
		// all of the rest of the DomainController/HistoryController data is already
		// a global single instance, so the model is the last element that needs to
		// populated via a single global access
		[Bindable]
		public var model:Model = Registry.getInstance(Model) as Model;
		
		// This is an example of a simple DomainController, methods only (no commands).
		
		public function initDrawing():void
		{
			model.phase = Phase.SETTINGS;
		}
		
		public function beginDrawing():void
		{
			model.phase = Phase.DRAWING;
		}
		
		public function previewDrawing():void
		{
			model.phase = Phase.PREVIEW;
		}
		
		
	}
}
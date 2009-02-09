package com.flightxd.flightdraw.domains.state
{
	import com.flightxd.flightdraw.domains.state.model.Phase;
	
	/**
	 * This is an example of a simple Model, a single class. Most often
	 * the model of a domain is a reference to a larger more complex
	 * system. It can be considered a model adapter or model locator.
	 */
	[Bindable]
	public class Model
	{
		
		public var phases:Array = [Phase.SETTINGS, Phase.DRAWING, Phase.SETTINGS];
		private var _phaseIndex:int = 0;
		private var _phase:String = phases[_phaseIndex];
		
		// below is an example of some simple behavior on a model -
		// phase and phaseIndex ensure each other are in sync.
		
		public function get phaseIndex():int
		{
			return _phaseIndex;
		}
		public function set phaseIndex(value:int):void
		{
			_phaseIndex = value;
			
			if(phase != phases[_phaseIndex]) {
				phase = phases[_phaseIndex];
			}
		}
		
		
		public function get phase():String
		{
			return _phase;
		}
		public function set phase(value:String):void
		{
			_phase = value;
			
			if(phaseIndex != phases.indexOf(phase)) {
				phaseIndex = phases.indexOf(phase);
			}
		}
		
	}
}
package tests.flight
{
	import flash.events.Event;
	
	import flexunit.flexui.TestRunnerBase;
	import flexunit.framework.TestSuite;
	
	import tests.flight.domain.TestDomainController;
	import tests.flight.domain.TestDomainModel;
	import tests.flight.domain.TestHistoryController;
	import tests.flight.registry.TestRegistry;
	
	public class FlightFrameworkTestRunner extends TestRunnerBase
	{
		override public function onCreationComplete():void
		{
			var testSuite:TestSuite = new TestSuite();
			
			// domain
			testSuite.addTestSuite( TestDomainController );
			testSuite.addTestSuite( TestDomainModel );
			testSuite.addTestSuite( TestHistoryController );
			
			// registry
			testSuite.addTestSuite( TestRegistry );
			
			test = testSuite;
			startTest();
		}
		
	}
}
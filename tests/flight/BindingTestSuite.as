package flight
{
	import flight.binding.BindTest;
	import flight.binding.BindingTest;
	import flight.binding.ObservingBindTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class BindingTestSuite
	{
		public var bindingTest:BindingTest;
		public var bindTest:BindTest;
		public var observingBindTest:ObservingBindTest;
	}
}
package flexUnitTests
{
	import flexUnitTests.binding.BindTest;
	import flexUnitTests.binding.BindingTest;
	import flexUnitTests.binding.ObservingBindTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class BindingTestSuite
	{
		public var bindingTest:BindingTest;
		public var bindTest:BindTest;
		public var observingBindTest:ObservingBindTest;
	}
}
package flight.utils
{
	public interface IValueObject
	{
		function equals(value:Object):Boolean;
		function clone():Object;
	}
}
package flight.utils
{
	public interface IValueObject
	{
		function equals(value:ValueObject):Boolean;
		function clone():ValueObject;
	}
}
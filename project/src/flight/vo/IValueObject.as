package flight.vo
{
	public interface IValueObject
	{
		function equals(value:Object):Boolean;
		function clone():Object;
	}
}
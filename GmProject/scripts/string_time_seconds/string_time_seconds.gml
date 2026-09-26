/// string_time_seconds(time, hours, milliseconds)
/// @arg time
/// @arg hours
/// @arg milliseconds

function string_time_seconds(time, hour = true, millisecond = true)
{
	return string_time(time * 1000, hour, millisecond)
}

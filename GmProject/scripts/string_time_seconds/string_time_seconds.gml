/// string_time_seconds(seconds)
/// @arg seconds

function string_time_seconds(secs)
{
	return string_time(secs div 3600, secs mod 3600 div 60, secs mod 60)
}

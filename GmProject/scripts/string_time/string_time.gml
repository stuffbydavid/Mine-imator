/// string_time(time, hours, milliseconds)
/// @arg time
/// @arg hours
/// @arg milliseconds

function string_time(time, hour = true, millisecond = true)
{
	var sep, hrs, mins, secs;
	
	sep = ":"
	hrs = floor(abs(time) div 3600000)
	mins = floor((abs(time) mod 3600000) div 60000)
	secs = millisecond ? ((abs(time) mod 60000) / 1000) : floor((abs(time) mod 60000) div 1000)
	
	return ((hour || hrs >= 1) ? (string_replace_all(string_format(hrs, hour ? 2 : 0, 0), " ", "0") + sep) : "") + // hours
		   string_replace_all(string_format(mins, 2, 0), " ", "0") + sep + // minutes
		   string_replace_all(string_format(secs, 2, millisecond ? 3 : 0), " ", "0"); // seconds
}

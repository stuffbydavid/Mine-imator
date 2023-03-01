/// string_time(hours, minutes, seconds)
/// @arg hours
/// @arg minutes
/// @arg seconds

function string_time(hours, mnts, secs)
{
	var sep = ":";
	
	return string_repeat("0", hours < 10) + string(hours) + sep +
		   string_repeat("0", mnts < 10) + string(mnts) + sep +
		   string_repeat("0", secs < 10) + string_replace_all(string_format(secs, 2, 3), " ", "");
}

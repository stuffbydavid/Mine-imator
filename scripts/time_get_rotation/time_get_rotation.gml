/// time_get_rotation(string)
/// @arg string
/// @desc Converts ToD string (ex. 1:13:14) into a rotational value

var str, colons, days, hours, minutes;
var colonpos, daystr, hourstr, minutestr;

str = argument0
colons = string_count(":", str)
days = 0
hours = 0
minutes = 0

// More than 2 colons, invalid
if (colons > 2)
	return 0

// No colons, assume hours
if (colons = 0)
	minutes = string_get_real(str, 0)

// Hours & minutes
if (colons = 1)
{
	// Split string based on colon
	colonpos = string_pos(":", str)
	hourstr = string_copy(str, 1, colonpos - 1)
	minutestr = string_delete(str, 1, colonpos)
	
	hours = string_get_real(hourstr, 0)
	minutes = string_get_real(minutestr, 0)
}

// Days, hours & minutes
if (colons = 2)
{
	// Split string based on colons
	colonpos = string_pos(":", str)
	daystr = string_copy(str, 1, colonpos - 1)
	
	// Filter out days
	str = string_delete(str, 1, colonpos)
	colonpos = string_pos(":", str)
	
	hourstr = string_copy(str, 1, colonpos - 1)
	minutestr = string_delete(str, 1, colonpos)
	
	days = string_get_real(daystr, 0)
	hours = string_get_real(hourstr, 0)
	minutes = string_get_real(minutestr, 0)
}

// Combine all variables
hours -= 12

return ((days + ((hours + (minutes / 60)) / 24)) * 360)
/// json_export_value(value)
/// @arg value

var value = argument0;

if (is_real(value))
	json_string += string_decimals(value)
else if (is_array(value))
	json_export_array(value, array_length_1d(value))
else
	json_string += "\"" + value + "\""
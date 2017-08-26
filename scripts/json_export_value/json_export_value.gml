/// json_export_value(value)
/// @arg value

var value = argument0;

if (is_real(value))
	buffer_write_string(string_decimals(value))
else if (is_array(value))
	json_export_array(value, array_length_1d(value))
else
{
	buffer_write_byte(e_json_char.QUOTE)
	buffer_write_string(value)
	buffer_write_byte(e_json_char.QUOTE)
}
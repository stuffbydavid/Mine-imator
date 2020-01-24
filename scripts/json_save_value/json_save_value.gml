/// json_save_value(value)
/// @arg value

var value = argument0;

if (is_real(value) || is_int32(value) || is_int64(value))
	buffer_write_string(string_decimals(value))
else if (is_array(value))
	json_save_array(value, array_length_1d(value))
else if (is_bool(value))
	buffer_write_string(string(value))
else
{
	buffer_write_byte(e_json_char.QUOTE)
	buffer_write_string(value)
	buffer_write_byte(e_json_char.QUOTE)
}
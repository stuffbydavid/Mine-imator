/// json_save_value(value)
/// @arg value

function json_save_value(val)
{
	if (is_real(val) || is_int32(val) || is_int64(val))
		buffer_write_string(string_decimals(val))
	else if (is_array(val))
		json_save_array(val, array_length(val))
	else if (is_bool(val))
		buffer_write_string(string(val))
	else
	{
		buffer_write_byte(e_json_char.QUOTE)
		buffer_write_string(val)
		buffer_write_byte(e_json_char.QUOTE)
	}
}

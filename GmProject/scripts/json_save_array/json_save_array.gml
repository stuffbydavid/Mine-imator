/// json_save_array(array, size)
/// @arg array
/// @arg size

function json_save_array(arr, size)
{
	buffer_write_byte(e_json_char.SQUARE_BEGIN)
	buffer_write_byte(e_json_char.SPACE)
	
	for (var i = 0; i < size; i++)
	{
		if (i > 0)
		{
			buffer_write_byte(e_json_char.COMMA)
			buffer_write_byte(e_json_char.SPACE)
		}
		
		json_save_value(arr[@i])
	}
	
	buffer_write_byte(e_json_char.SPACE)
	buffer_write_byte(e_json_char.SQUARE_END)
}

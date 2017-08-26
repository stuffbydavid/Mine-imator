/// json_export_array(array, size)
/// @arg array
/// @arg size

var arr, size;
arr = argument0
size = argument1

buffer_write_byte(e_json_char.SQUARE_BEGIN)
buffer_write_byte(e_json_char.SPACE)

for (var i = 0; i < size; i++)
{
	if (i > 0)
	{
		buffer_write_byte(e_json_char.COMMA)
		buffer_write_byte(e_json_char.SPACE)
	}
	
	json_export_value(arr[@i])
}

buffer_write_byte(e_json_char.SPACE)
buffer_write_byte(e_json_char.SQUARE_END)
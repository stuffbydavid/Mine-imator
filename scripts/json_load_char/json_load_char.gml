/// json_load_char()
/// @desc Loads the next JSON character, skips whitespaces.

if (buffer_is_eof())
{
	json_error = "Unexpected end of file"
	return false
}

do
{
	json_char = buffer_read_byte()
	
	if (json_char = e_json_char.TAB)
		json_column += 4
	else if (json_char = e_json_char.NEW_LINE)
	{
		json_line++
		json_column = 0
	}
	else
		json_column++
}
until (json_char != e_json_char.TAB &&
	   json_char != e_json_char.SPACE && 
	   json_char != e_json_char.NEW_LINE && 
	   json_char != e_json_char.RETURN &&
	   json_char < 127)

return true

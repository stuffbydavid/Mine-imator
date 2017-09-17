/// json_load_string()

var str = "";

while (true)
{
	if (buffer_is_eof())
	{
		json_error = "Unexpected end of file"
		return false
	}
	
	json_char = buffer_read_byte()
	json_column++
	
	// End of string
	if (json_char = e_json_char.QUOTE)
		break
	
	// Invalid linebreak in string	
	if (json_char = e_json_char.RETURN || json_char = e_json_char.NEW_LINE)
	{
		json_error = "Unexpected linebreak in string"
		return false
	}
	
	// Special character
	if (json_char = e_json_char.BACKSLASH)
	{
		if (buffer_is_eof())
		{
			json_error = "Unexpected end of file"
			return false
		}
	
		json_char = buffer_read_byte()
		json_column++
		
		if (json_char = e_json_char.QUOTE)
			str += "\""
		else if (json_char = e_json_char.BACKSLASH)
			str += "\\"
		else if (json_char = e_json_char.N)
			str += "\n"
		else if (json_char = e_json_char.T)
			str += "\t"
		else if (json_char = e_json_char.U)
		{
			// Parse Hex ascii code
			var hex = ""
			repeat (4)
			{
				if (buffer_is_eof())
				{
					json_error = "Unexpected end of file"
					return false
				}
				
				json_char = buffer_read_byte()
				json_column++
				
				hex += chr(json_char)
			}
			str += chr(hex_to_dec(hex))
		}
	}
	else
		str += chr(json_char)
}

// Next
if (!json_load_char())
	return false

json_value = str
json_value_type = e_json_type.STRING

return true

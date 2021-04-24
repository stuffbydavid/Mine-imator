/// json_load_number()

function json_load_number()
{
	var str, expart, ex;
	str = ""
	expart = false
	ex = ""
	
	do
	{
		if (!expart)
			str += chr(json_char)
		else
			ex += chr(json_char)
		
		json_char = buffer_read_byte()
		json_column++
		
		if (buffer_is_eof())
		{
			json_error = "Unexpected end of file"
			return false
		}
		
		// Exponent
		if (json_char = e_json_char.E || json_char = e_json_char.CAPITAL_E)
		{
			if (expart)
			{
				json_error = "Unexpected symbol"
				return false
			}
			
			json_char = buffer_read_byte()
			json_column++
			
			if (buffer_is_eof())
			{
				json_error = "Unexpected end of file"
				return false
			}
			
			expart = true
		}
	}
	until ((json_char < e_json_char.NUM_0 || json_char > e_json_char.NUM_9) &&
			json_char != e_json_char.POINT && json_char != e_json_char.MINUS && json_char != e_json_char.PLUS)
	
	// Skip whitespace
	if (json_char = e_json_char.TAB ||
		json_char = e_json_char.SPACE ||
		json_char = e_json_char.NEW_LINE ||
		json_char = e_json_char.RETURN)
	{
		if (!json_load_char())
			return false
	}
	
	json_value = string_get_real(str)
	json_value_type = e_json_type.NUMBER
	
	if (expart)
		json_value = power(json_value, string_get_real(ex))
	
	if (is_undefined(json_value))
	{
		json_error = "Invalid number \"" + str + "\""
		return false
	}
	
	return true
}

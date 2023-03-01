/// json_load_word()

function json_load_word()
{
	if (json_char = e_json_char.T)
	{
		repeat (4)
			if (!json_load_char())
				return false
		
		json_value = true
		json_value_type = e_json_type.BOOL
	}
	else if (json_char = e_json_char.F)
	{
		repeat (5)
			if (!json_load_char())
				return false
		
		json_value = false
		json_value_type = e_json_type.BOOL
	}
	else if (json_char = e_json_char.N)
	{
		repeat (4)
			if (!json_load_char())
				return false
		
		json_value = null
		json_value_type = e_json_type.NULL
	}
	else
	{
		json_error = "Unrecognized word"
		return false
	}
	
	return true
}

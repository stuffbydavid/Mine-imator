/// json_load_value()

function json_load_value()
{
	if (json_char = e_json_char.CURLY_BEGIN)
		return json_load_object(false)
	else if (json_char = e_json_char.SQUARE_BEGIN)
		return json_load_array()
	else if (json_char = e_json_char.QUOTE)
		return json_load_string()
	else if ((json_char >= e_json_char.NUM_0 && json_char <= e_json_char.NUM_9) || json_char = e_json_char.MINUS)
		return json_load_number()
	else
		return json_load_word()
}

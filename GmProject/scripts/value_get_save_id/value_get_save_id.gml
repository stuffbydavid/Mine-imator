/// value_get_save_id(value, [default])
/// @arg value
/// @arg [default]

function value_get_save_id(val, def = "")
{
	if (is_string(val))
	{
		if (val = "null")
			return null
		
		return val
	}
	
	return def
}

/// @arg value
/// @arg [default]

function value_get_save_id(val, def = "")
{
	if (def != "")
		def = save_id_get(def)
	
	if (is_string(val))
	{
		if (val = "null")
			return null
		
		return val
	}

	if (is_real(val) && val < 0)
		return val
	
	return def
}

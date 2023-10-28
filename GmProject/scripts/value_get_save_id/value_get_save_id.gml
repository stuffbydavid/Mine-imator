/// value_get_save_id(value, [default])
/// @arg value
/// @arg [default]

function value_get_save_id()
{
	var val, def;
	val = argument[0]
	def = ""
	if (argument_count > 1)
		def = save_id_get(argument[1])
	
	if (is_string(val))
	{
		if (val = "null")
			return null
		
		return val
	}
	
	return def
}
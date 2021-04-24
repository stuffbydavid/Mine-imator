/// value_get_string(value, [default])
/// @arg value
/// @arg [default]

function value_get_string()
{
	var val, def;
	val = argument[0]
	if (argument_count > 1)
		def = argument[1]
	else
		def = ""
	
	if (is_string(val))
		return val
	
	return def
}

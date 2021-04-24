/// value_get_real(value, [default])
/// @arg value
/// @arg [default]

function value_get_real()
{
	var val, def;
	val = argument[0]
	def = null
	
	if (argument_count > 1)
		def = argument[1]
	
	if (is_real(val))
		return val
	else if (is_string(val) && val = "null")
		return null
	
	return def
}

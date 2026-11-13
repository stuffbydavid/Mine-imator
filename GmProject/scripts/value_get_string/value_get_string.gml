/// @arg value
/// @arg [default]

function value_get_string(val, def = "")
{
	if (is_string(val))
		return val
	
	return def
}

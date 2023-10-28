/// value_get_color(value, [default])
/// @arg value
/// @arg [default]

function value_get_color(val, def = -1)
{
	if (is_string(val))
		return hex_to_color(val)
	
	return def
}

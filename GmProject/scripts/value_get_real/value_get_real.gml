/// value_get_real(value, [default])
/// @arg value
/// @arg [default]

function value_get_real(val, def = null)
{
	if (is_int32(val) || is_int64(val) || is_real(val) || is_bool(val))
		return val
	else if (is_string(val) && val = "null")
		return null
	
	return def
}

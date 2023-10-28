/// value_get_array(value, [default])
/// @arg value
/// @arg [default]

function value_get_array(val, def = null)
{
	if (ds_list_valid(val))
		return ds_list_create_array(val)
	
	return def
}

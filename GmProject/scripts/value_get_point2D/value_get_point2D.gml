/// value_get_point2D(value, [default])
/// @arg value
/// @arg [default]

function value_get_point2D(val, def = null)
{
	if (ds_list_valid(val) && ds_list_size(val) >= 2)
		return point2D(val[|X], val[|Y])
	
	return def
}

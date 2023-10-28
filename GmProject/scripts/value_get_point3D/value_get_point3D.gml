/// value_get_point3D(value, [default])
/// @arg value
/// @arg [default]

function value_get_point3D(val, def = null)
{
	if (ds_list_valid(val) && ds_list_size(val) >= 3)
		return point3D(val[|X], val[|Z], val[|Y])
	
	return def
}

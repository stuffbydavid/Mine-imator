/// value_get_point3D(value, [default])
/// @arg value
/// @arg [default]

var val, def;
val = argument[0];
if (argument_count > 1)
	def = argument[1]
else
	def = null
	
if (ds_list_valid(val) && ds_list_size(val) = 3)
	return point3D(val[|X], val[|Z], val[|Y])

return def
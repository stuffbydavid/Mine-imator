/// value_get_array(value, [default])
/// @arg value
/// @arg [default]

var val, def;
val = argument[0];
if (argument_count > 1)
	def = argument[1]
else
	def = null
	
if (ds_list_valid(val))
	return ds_list_create_array(val)

return def
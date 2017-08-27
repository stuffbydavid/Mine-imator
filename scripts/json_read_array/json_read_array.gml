/// json_read_array(value, [default])
/// @arg value
/// @arg [default]

var val, def;
val = argument[0];
if (argument_count > 1)
	def = argument[1]
else
	def = null
	
if (ds_exists(val, ds_type_list))
{
	var arr;
	for (var i = 0; i < ds_list_size(val); i++)
		arr[i] = val[|i]
		
	return arr
}

return def
/// value_get_save_id(value, [default])
/// @arg value
/// @arg [default]

var val, def;
val = argument[0]
if (argument_count > 1)
	def = save_id_get(argument[1])
else
	def = ""
	
if (is_string(val))
{
	if (val = "null")
		return null
	
	return val
}

return def
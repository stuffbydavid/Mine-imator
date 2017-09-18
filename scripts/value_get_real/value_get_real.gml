/// json_read_real(value, [default])
/// @arg value
/// @arg [default]

var val, def;
val = argument[0]
if (argument_count > 1)
	def = argument[1]
else
	def = null
	
if (is_real(val))
	return val
else if (is_string(val) && val = "null")
	return null
	
return def
/// value_get_color(value, [default])
/// @arg value
/// @arg [default]

var val, def;
val = argument[0]
if (argument_count > 1)
	def = argument[1]
else
	def = -1
	
if (is_string(val))
	return hex_to_color(val)
	
return def
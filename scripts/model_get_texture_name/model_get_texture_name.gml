/// model_get_texture_name(map, name)
/// @arg map
/// @arg name

var map, name;
map = argument0
name = argument1

if (!is_undefined(map[?name]))
	return map[?name]
else if (!is_undefined(map[?""]))
	return map[?""]
	
return ""
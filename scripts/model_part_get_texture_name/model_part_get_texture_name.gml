/// model_part_get_texture_name(part, map)
/// @arg part
/// @arg map

var part, map, key;
part = argument0
map = argument1

if (part = null)
	return map[?""]

if (part.object_index = obj_model_part)
	key = part.name
else // Root
	key = ""

// State-specific texture
if (!is_undefined(map[?key]))
	return map[?key]
	
// Part-specific texture
if (part.texture_name != "")
	return part.texture_name

// Get texture of inherited part
return model_part_get_texture_name(part.texture_inherit, map)
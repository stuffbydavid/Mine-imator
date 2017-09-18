/// model_part_texture_name(map, part)
/// @arg map
/// @arg part

var map, part, key;
map = argument0
part = argument1

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
return model_part_texture_name(map, part.texture_inherit)
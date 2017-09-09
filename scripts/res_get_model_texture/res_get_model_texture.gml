/// res_get_model_texture(name)
/// @arg name
/// @desc Returns the model texture with the given name from a skin or texture pack.

var name = argument0;

if (type = "pack")
{
	if (ds_map_exists(model_texture_map, name))
		return model_texture_map[?name]
	else
		return null
}
else
	return model_texture
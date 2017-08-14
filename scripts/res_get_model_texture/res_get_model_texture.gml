/// res_get_model_texture(name)
/// @arg name

var name = argument0;

if (type = "pack")
{
	return model_texture_map[?name]
}
else
	return model_texture
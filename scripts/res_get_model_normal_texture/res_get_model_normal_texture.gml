/// res_get_model_normal_texture(name)
/// @arg name
/// @desc Returns the model normal texture with the given name from a skin or texture pack.

function res_get_model_normal_texture(name)
{
	if (!ready)
		return null
	
	if (model_normal_texture_map != null)
	{
		if (ds_map_exists(model_normal_texture_map, name))
			return model_normal_texture_map[?name]
		else
			return null
	}
	else if (model_texture != null)
		return model_texture
	else
		return null
}

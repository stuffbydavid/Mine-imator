/// res_get_model_tex_normal(name)
/// @arg name
/// @desc Returns the model normal texture with the given name from a skin or texture pack.

function res_get_model_tex_normal(name)
{
	if (!ready)
		return null
	
	if (model_tex_normal_map != null)
	{
		if (ds_map_exists(model_tex_normal_map, name))
			return model_tex_normal_map[?name]
		else
			return null
	}
	else if (model_texture != null)
		return model_texture
	else
		return null
}

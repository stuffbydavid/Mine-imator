/// res_get_model_texture(name)
/// @arg name
/// @desc Returns the model texture with the given name from a skin or texture pack.

function res_get_model_texture(name)
{
	if (!ready)
		return null
	
	if (model_texture_map != null)
	{
		var tex = ds_map_find_value(model_texture_map, name);
		return is_undefined(tex) ? null : tex;
	}
	else
		return model_texture
}

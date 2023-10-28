/// temp_get_model_texobj(value)
/// @arg value
/// @desc Returns the resource whose texture to use when rendering instances of the template.
/// A value (id) is supplied from a keyframe, if none is available then it is null.

function temp_get_model_texobj(texobj)
{
	if (texobj = null || texobj = 0 || texobj.type = e_tl_type.CAMERA || // Check if empty or a camera
		(texobj.model_texture = null && texobj.model_texture_map = null)) // Not a valid model texture, use the library setting
	{
		// Animatable block in scenery, use scenery's library setting(If it's a pack)
		if (object_index = obj_timeline && type = e_tl_type.SPECIAL_BLOCK)
		{
			if (part_of.type = e_tl_type.SCENERY)
			{
				with (part_of)
				{
					if (temp.block_tex && temp.block_tex.type = e_res_type.PACK)
						texobj = temp.block_tex
					else
						texobj = mc_res
				}
			}
		}
		else
			texobj = model_tex
	}	
	
	if (texobj = null) // Use the model's texture
	{
		texobj = model
		if (texobj != null)
		{
			if (texobj.model_format = e_model_format.BLOCK)
			{
				if (texobj.model_texture_map = null && texobj.block_sheet_texture = null) // Model has no texture, use Minecraft
					texobj = mc_res
			}
			else
			{
				if (texobj.model_texture_map = null && texobj.model_texture = null) // Model has no texture, use Minecraft
					texobj = mc_res
			}
		}
	}
	
	return texobj
}

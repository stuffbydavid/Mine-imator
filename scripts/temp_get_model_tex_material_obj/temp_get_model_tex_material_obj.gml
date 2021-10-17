/// temp_get_model_tex_material_obj(value)
/// @arg value
/// @desc Returns the resource whose texture to use when rendering instances of the template.
///		  A value (id) is supplied from a keyframe, if none is available then it is null.

function temp_get_model_tex_material_obj(texobj)
{
	if (texobj = null || texobj = 0 || texobj.type = e_tl_type.CAMERA ||  // Check if empty or a camera
		(texobj.model_texture = null && texobj.model_material_texture_map = null)) // Not a valid model texture, use the library setting
	{
		// Animatable block in scenery, use scenery's library setting(If it's a pack)
		if (object_index = obj_timeline && type = e_tl_type.SPECIAL_BLOCK)
		{
			if (part_of.type = e_tl_type.SCENERY)
			{
				with (part_of)
				{
					if (temp.block_material_tex.type = e_res_type.PACK)
						texobj = temp.block_material_tex
					else
						texobj = mc_res
				}
			}
		}
		else
			texobj = model_material_tex
	}	
	
	if (texobj = null) // Use the model's texture
	{
		texobj = model
		
		if (texobj != null && texobj.model_material_texture_map = null && texobj.model_texture = null) // Model has no texture
			texobj = null
	}
	
	return texobj
}

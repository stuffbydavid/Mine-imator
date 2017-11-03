/// temp_get_model_texobj(value)
/// @arg value
/// @desc Returns the resource whose texture to use when rendering instances of the template.
///		  A value (id) is supplied from a keyframe, if none is available then it is null.

var texobj = argument0;

if (texobj = null || texobj = 0 || texobj.type = e_tl_type.CAMERA ||  // Check if empty or a camera
	(texobj.model_texture = null && texobj.model_texture_map = null)) // Not a valid model texture, use the library setting
	texobj = model_tex
			
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
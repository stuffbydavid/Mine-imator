/// temp_get_shape_tex(textureobject, [default])
/// @arg textureobject

function temp_get_shape_tex(texobj, def = undefined)
{
	if (texobj != null)
	{
		if (texobj.type = e_tl_type.CAMERA)
		{
			shader_texture_surface = true
			return texobj.cam_surf
		}
		else
			return texobj.texture
	}
	
	if (def != undefined)
		return def
	else
		return shape_texture
}

/// temp_get_shape_tex(textureobject)
/// @arg textureobject

function temp_get_shape_tex(texobj)
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
	
	return shape_texture
}

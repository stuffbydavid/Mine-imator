/// @arg textureobject
/// @arg [default]

function temp_get_shape_tex(texobj, def = null)
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
	
	if (def != null)
		return def
	else
		return spr_shape
}

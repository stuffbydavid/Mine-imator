/// temp_get_shape_tex(textureobject)
/// @arg textureobject

var texobj = argument0;

if (texobj != null)
{
	if (texobj.type = "camera")
	{
		shader_texture_surface = true
		return texobj.cam_surf
	}
	else
		return texobj.texture
}

return shape_texture

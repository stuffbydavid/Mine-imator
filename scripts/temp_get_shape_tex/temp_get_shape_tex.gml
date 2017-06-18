/// temp_get_shape_tex(textureobject)
/// @arg textureobject

var texobj = argument0;

if (texobj)
{
	if (texobj.type = "camera")
	{
		shader_texture_gm = true
		return surface_get_texture(texobj.cam_surf)
	}
	else
		return texobj.texture
}

shader_texture_gm = true
return sprite_get_texture(spr_shape, 0)

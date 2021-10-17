/// temp_get_model_tex_normal_preview(textureobject, part)
/// @arg textureobject
/// @arg part

function temp_get_model_tex_normal_preview(texobj, part)
{
	if (texobj = null)
		return null
	
	if (object_index != obj_timeline && model != null && model.model_format = e_model_format.BLOCK) // Not scenery timeline and model is a .json
		return texobj.block_preview_texture
	
	with (texobj)
		return res_get_model_normal_texture(model_part_get_normal_texture_name(part, other.model_normal_texture_name_map))
}

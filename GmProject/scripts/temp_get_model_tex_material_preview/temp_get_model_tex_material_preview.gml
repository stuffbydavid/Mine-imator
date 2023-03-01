/// temp_get_model_tex_material_preview(textureobject, part)
/// @arg textureobject
/// @arg part

function temp_get_model_tex_material_preview(texobj, part)
{
	if (texobj = null)
		return null
	
	if (object_index != obj_timeline && model != null && model.model_format = e_model_format.BLOCK) // Not scenery timeline and model is a .json
		return texobj.block_preview_texture
	
	with (texobj)
		return res_get_model_texture_material(model_part_get_texture_material_name(part, other.model_texture_material_name_map))
}

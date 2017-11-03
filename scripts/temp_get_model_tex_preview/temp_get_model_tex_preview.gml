/// temp_get_model_tex_preview(textureobject, part)
/// @arg textureobject
/// @arg part

var texobj, part;
texobj = argument0
part = argument1

if (texobj = null || model = null)
	return null

if (model.model_format = e_model_format.BLOCK)
	return texobj.block_preview_texture

with (texobj)
	return res_get_model_texture(model_part_get_texture_name(part, other.model_texture_name_map))
/// @desc Returns whether the timeline object is rendered using alpha hashing.

function tl_get_alpha_hashing()
{
	var hashed = (alpha_mode = e_alpha_mode.HASHED || (alpha_mode = e_alpha_mode.DEFAULT && app.project_render_alpha_mode = e_alpha_mode.HASHED));
	if (!hashed)
		return false
	
	if (!type_is_visible(type) || type_is_light(type) || type = e_tl_type.CAMERA)
		return false
		
	if (!value_inherit[e_value.VISIBLE] ||
		(hide && !render_hidden) ||
		(value_inherit[e_value.ALPHA] * 1000) = 0 ||
		(glow && only_render_glow) ||
		(!app.place_tl_render && (placed || parent_is_placed)))
		return false

	if (type = e_tl_type.MODEL && (temp.model = null || temp.model.model_format = e_model_format.MIMODEL))
		return false

	return true
}

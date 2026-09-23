/// render_alpha_hashing_update()

function render_alpha_hashing_update()
{
	render_alpha_hashed_count = 0
	with (obj_timeline)
		if (render_alpha_hashing_used())
			other.render_alpha_hashed_count++
}

function render_alpha_hashing_used()
{
	if (!value_inherit[e_value.VISIBLE] || (hide && !render_hidden) || (value_inherit[e_value.ALPHA] * 1000) = 0 ||
		(glow && only_render_glow) || (!app.place_tl_render && (placed || parent_is_placed)))
		return false

	switch (type)
	{
		case e_tl_type.CHARACTER:
		case e_tl_type.SPECIAL_BLOCK:
		case e_tl_type.FOLDER:
		case e_tl_type.BACKGROUND:
		case e_tl_type.AUDIO_TRACK:
		case e_tl_type.PATH_POINT:
		case e_tl_type.SPOT_LIGHT:
		case e_tl_type.POINT_LIGHT:
		case e_tl_type.CAMERA:
			return false
	}

	if (type = e_tl_type.MODEL && (temp.model = null || temp.model.model_format = e_model_format.MIMODEL))
		return false

	return alpha_mode = e_alpha_mode.HASHED || (alpha_mode = e_alpha_mode.DEFAULT && app.project_render_alpha_mode = e_alpha_mode.HASHED)
}

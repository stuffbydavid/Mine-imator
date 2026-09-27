/// tl_new_text(source)
/// @arg source

function tl_new_text(source)
{
	with (new_obj(obj_timeline))
	{
		type = e_tl_type.TEXT
		temp = id
		has_temp = false
		animated = false
		text_font = source.text_font
		text_3d = source.text_3d
		text_face_camera = source.text_face_camera
		text_aa = source.text_aa
		value[e_value.TEXT] = source.text != "" ? source.text : text_get("frameeditortextsample")
		value[e_value.TEXT_OUTLINE] = source.text_outline
		value[e_value.TEXT_OUTLINE_COLOR] = source.text_outline_color
		value[e_value.TEXT_OUTLINE_SIZE] = source.text_outline_size
		value[e_value.TEXT_HALIGN] = source.text_halign
		value[e_value.TEXT_VALIGN] = source.text_valign
		temp_update_rot_point()
		tl_update()
		tl_set_parent_root()
		tl_value_spawn()

		return id
	}
}

function tl_create_temp_copy(to)
{
	to.type = type
	to.name = name

	if (type = e_tl_type.BLOCK)
	{
		to.block_name = block_name
		to.block_state = array_copy_1d(block_state)
		to.block_tex = block_tex
		to.block_tex_material = block_tex_material
		to.block_tex_normal = block_tex_normal
		to.block_repeat_enable = block_repeat_enable
		to.block_repeat = array_copy_1d(block_repeat)
		to.block_center_legacy = block_center_legacy
		to.block_center = block_center
		to.block_randomize = block_randomize
	}
	else if (type = e_tl_type.TEXT)
	{
		to.text_font = text_font
		to.text_3d = text_3d
		to.text_face_camera = text_face_camera
		to.text_aa = text_aa
		if (object_index = obj_timeline)
		{
			to.text_outline = value[e_value.TEXT_OUTLINE]
			to.text_outline_color = value[e_value.TEXT_OUTLINE_COLOR]
			to.text_outline_size = value[e_value.TEXT_OUTLINE_SIZE]
			to.text_halign = value[e_value.TEXT_HALIGN]
			to.text_valign = value[e_value.TEXT_VALIGN]
		}
	}
	else
	{
		to.model_name = model_name
		to.model_state = array_copy_1d(model_state)
		to.model_tex = model_tex
		to.model_tex_material = model_tex_material
		to.model_tex_normal = model_tex_normal
		to.model_use_blend_color = model_use_blend_color
		to.model_blend_color = model_blend_color
		to.model_blend_color_default = model_blend_color_default
		to.pattern_type = pattern_type
		to.pattern_base_color = pattern_base_color
		to.pattern_pattern_list = array_copy_1d(pattern_pattern_list)
		to.pattern_color_list = array_copy_1d(pattern_color_list)
	}
}

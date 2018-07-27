/// tl_update_scenery_part()

if (part_of = null)
	return 0

if (type = e_tl_type.SPECIAL_BLOCK)
{
	model_tex = mc_res
	model_file = null
	model_texture_name_map = null
	model_hide_list = null
	model_color_name_map = null
	model_color_map = null
	model_shape_vbuffer_map = null
	temp_update_model()
	temp_update_model_timeline_parts()
}
else if (type = e_tl_type.BLOCK)
{
	block_tex = mc_res
	block_repeat_enable = false
	block_repeat = vec3(1)
	block_vbuffer = null
	temp_update_block()
}
else if (type = e_tl_type.TEXT)
{
	text_font = mc_res
	text_3d = false
	text_face_camera = false
}
/// tl_update_scenery_part()

if (part_of = null)
	return 0

if (type = "spblock")
{
	skin = res_def
	model_state_map = null
	model_file = null
	model_texture_name_map = null
	temp_update_model_state_map()
	temp_update_model()
	temp_update_model_timeline_parts()
}
else if (type = "block")
{
	block_tex = res_def
	block_state_map = null
	block_repeat_enable = false
	block_repeat = vec3(1)
	block_vbuffer_reset()
	temp_update_block_state_map()
	temp_update_block()
}
else if (type = "text")
{
	text_font = res_def
	text_3d = false
	text_face_camera = false
}
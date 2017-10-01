/// tl_update_scenery_part()

if (part_of = null)
	return 0

if (type = "spblock")
{
	skin = mc_res
	model_file = null
	model_texture_name_map = null
	temp_update_model()
	temp_update_model_timeline_parts()
}
else if (type = "block")
{
	block_tex = mc_res
	block_repeat_enable = false
	block_repeat = vec3(1)
	block_vbuffer_reset()
	temp_update_block()
}
else if (type = "text")
{
	text_font = mc_res
	text_3d = false
	text_face_camera = false
}
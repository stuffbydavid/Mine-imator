/// tl_update_scenery_part()

function tl_update_scenery_part()
{
	if (part_of = null && !((type = e_tl_type.BLOCK || type = e_tl_type.SPECIAL_BLOCK) && !has_temp))
		return 0
	
	if (type = e_tl_type.SPECIAL_BLOCK)
	{
		if (part_of != null || has_temp)
		{
			model_tex = project_pack_res
			model_tex_material = project_pack_res
			model_tex_normal = project_pack_res
		}
		temp_update_model()
		temp_update_model_timeline_parts()
	}
	else if (type = e_tl_type.BLOCK)
	{
		if (part_of != null || has_temp)
		{
			block_tex = project_pack_res
			block_tex_material = project_pack_res
			block_tex_normal = project_pack_res
			block_repeat_enable = false
			block_repeat = vec3(1)
		}
		block_vbuffer = null
		if (part_of != null || has_temp)
			block_randomize = true
		temp_update_block()
	}
	else if (type = e_tl_type.TEXT)
	{
		text_font = project_pack_res
		text_3d = false
		text_face_camera = false
	}
}

/// project_save_template()

json_save_object_start()

	json_save_var("id", save_id)
	json_save_var("type", type)
	json_save_var("name", json_string_encode(name))
	
	if (type = "char" || type = "spblock" || type = "bodypart")
	{
		json_save_var_save_id("skin", skin)
		json_save_object_start("model")
			json_save_var("name", model_name)
			json_save_var("state", model_state)
			if (type = "bodypart")
				json_save_var("part_name", model_part_name)
		json_save_object_done()
	}
	else if (type = "item")
	{
		json_save_object_start("item")
			json_save_var_save_id("tex", item_tex)
			
			if (item_tex.type = "pack" && item_slot < ds_list_size(mc_assets.item_texture_list))
				json_save_var("name", mc_assets.item_texture_list[|item_slot])
			else
				json_save_var("slot", item_slot)
				
			json_save_var_bool("3d", item_3d)
			json_save_var_bool("face_camera", item_face_camera)
			json_save_var_bool("bounce", item_bounce)
		json_save_object_done()
	}
	else if (type = "block")
	{
		json_save_object_start("block")
			json_save_var("name", block_name)
			json_save_var("state", block_state)
			json_save_var_save_id("tex", block_tex)
			json_save_var_bool("repeat_enable", block_repeat_enable)
			json_save_var_point3D("repeat", block_repeat)
		json_save_object_done()
	}
	if (type = "scenery")
	{
		json_save_var_save_id("scenery", scenery)
		json_save_object_start("block")
			json_save_var_save_id("tex", block_tex)
			json_save_var_bool("repeat_enable", block_repeat_enable)
			json_save_var_point3D("repeat", block_repeat)
		json_save_object_done()
	}
	
	if (type_is_shape(type))
	{
		json_save_object_start("shape")
			json_save_var_save_id("tex", shape_tex)
			json_save_var_bool("tex_mapped", shape_tex_mapped)
			json_save_var("tex_hoffset", shape_tex_hoffset)
			json_save_var("tex_voffset", shape_tex_voffset)
			json_save_var("tex_hrepeat", shape_tex_hrepeat)
			json_save_var("tex_vrepeat", shape_tex_vrepeat)
			json_save_var_bool("tex_hmirror", shape_tex_hmirror)
			json_save_var_bool("tex_vmirror", shape_tex_vmirror)
			json_save_var_bool("closed", shape_closed)
			json_save_var_bool("invert", shape_invert)
			json_save_var("detail", shape_detail)
			json_save_var_bool("face_camera", shape_face_camera)
		json_save_object_done()
	}
	else if (type = "text")
	{
		json_save_object_start("text")
			json_save_var_save_id("font", text_font)
			json_save_var_bool("3d", text_3d)
			json_save_var_bool("face_camera", text_face_camera)
		json_save_object_done()
	}
	else if (type = "particles")
		project_save_particles()
	
json_save_object_done()
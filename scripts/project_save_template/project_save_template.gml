/// project_save_template()

json_export_object_start()

	json_export_var("id", save_id)
	json_export_var("type", type)
	json_export_var("name", json_string_encode(name))
	
	if (type = "char" || type = "spblock" || type = "bodypart")
	{
		json_export_var_save_id("skin", skin)
		json_export_object_start("model")
			json_export_var("name", model_name)
			json_export_var("state", model_state)
			if (type = "bodypart")
				json_export_var("part_name", model_part_name)
		json_export_object_done()
	}
	else if (type = "item")
	{
		json_export_object_start("item")
			json_export_var_save_id("tex", item_tex)
			
			if (item_tex.type = "pack" && item_slot < ds_list_size(mc_assets.item_texture_list))
				json_export_var("name", mc_assets.item_texture_list[|item_slot])
			else
				json_export_var("slot", item_slot)
				
			json_export_var_bool("3d", item_3d)
			json_export_var_bool("face_camera", item_face_camera)
			json_export_var_bool("bounce", item_bounce)
		json_export_object_done()
	}
	else if (type = "block")
	{
		json_export_object_start("block")
			json_export_var("name", block_name)
			json_export_var("state", block_state)
			json_export_var_save_id("tex", block_tex)
			json_export_var_bool("repeat_enable", block_repeat_enable)
			json_export_var("repeat", block_repeat)
		json_export_object_done()
	}
	if (type = "scenery")
	{
		json_export_var_save_id("scenery", scenery)
		json_export_object_start("block")
			json_export_var_save_id("tex", block_tex)
			json_export_var_bool("repeat_enable", block_repeat_enable)
			json_export_var("repeat", block_repeat)
		json_export_object_done()
	}
	
	if (type_is_shape(type))
	{
		json_export_object_start("shape")
			json_export_var_save_id("tex", shape_tex)
			json_export_var_bool("tex_mapped", shape_tex_mapped)
			json_export_var("tex_hoffset", shape_tex_hoffset)
			json_export_var("tex_voffset", shape_tex_voffset)
			json_export_var("tex_hrepeat", shape_tex_hrepeat)
			json_export_var("tex_vrepeat", shape_tex_vrepeat)
			json_export_var_bool("tex_hmirror", shape_tex_hmirror)
			json_export_var_bool("tex_vmirror", shape_tex_vmirror)
			json_export_var_bool("closed", shape_closed)
			json_export_var_bool("invert", shape_invert)
			json_export_var("detail", shape_detail)
			json_export_var_bool("face_camera", shape_face_camera)
		json_export_object_done()
	}
	else if (type = "text")
	{
		json_export_object_start("text")
			json_export_var_save_id("font", text_font)
			json_export_var_bool("3d", text_3d)
			json_export_var_bool("face_camera", text_face_camera)
		json_export_object_done()
	}
	else if (type = "particles")
		project_save_particles()
	
json_export_object_done()
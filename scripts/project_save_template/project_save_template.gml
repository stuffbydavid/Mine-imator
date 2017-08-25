/// project_save_template()

json_export_object_start()

	json_export_var("id", save_id)
	json_export_var("type", type)
	json_export_var("name", string_escape(name))
	
	if (type = "char" || type = "spblock" || type = "bodypart")
	{
		json_export_var_obj("skin", skin)
		json_export_var("model_name", model_name)
		json_export_var("model_state", model_state)
		json_export_var("model_part_name", model_part_name)
	}
	else if (type = "item")
	{
		json_export_var_obj("item_tex", item_tex)
		json_export_var("item_slot", item_slot)
		json_export_var_bool("item_3d", item_3d)
		json_export_var_bool("item_face_camera", item_face_camera)
		json_export_var_bool("item_bounce", item_bounce)
	}
	else if (type = "block")
	{
		json_export_var("block_name", block_name)
		json_export_var("block_state", block_state)
		json_export_var_obj("block_tex", block_tex)
	}
	if (type = "scenery")
		json_export_var_obj("scenery", scenery)
		
	if (type = "block" || type = "scenery")
	{
		json_export_var_bool("block_repeat_enable", block_repeat_enable)
		json_export_var("block_repeat", block_repeat)
	}
	
	if (type_is_shape(type))
	{
		json_export_object_start("shape")
		
			json_export_var_obj("tex", shape_tex)
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
		json_export_var_obj("text_font", text_font)
		json_export_var_bool("text_face_camera", text_face_camera)
	}
	else if (type = "particles")
		project_save_particles()
	
json_export_object_done()
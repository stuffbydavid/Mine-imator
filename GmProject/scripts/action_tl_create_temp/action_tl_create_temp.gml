/// action_tl_create_temp()

function action_tl_create_temp()
{
	var hobj, roottl, newtemp;
	hobj = null
	roottl = null
	newtemp = null

	if (history_undo)
	{
		// Restore timeline ownership
		roottl = save_id_find(history_data.tl_save_id)
		newtemp = save_id_find(history_data.temp_save_id)
		if (roottl = null || newtemp = null)
			return 0

		with (newtemp)
			tl_create_temp_copy(roottl)

		if (roottl.type = e_tl_type.BLOCK)
		{
			roottl.block_vbuffer = newtemp.block_vbuffer
			newtemp.block_vbuffer = null
		}
		else if (roottl.type = e_tl_type.SPECIAL_BLOCK)
			with (newtemp)
				tl_create_temp_move_model(roottl)
		
		with (newtemp)
			tl_create_temp_move_pattern_update(roottl)

		with (obj_timeline)
		{
			if (temp != newtemp)
				continue

			id.temp = roottl
			has_temp = false
		}

		with (roottl)
		{
			if (type = e_tl_type.SPECIAL_BLOCK)
				temp_update_model_timeline_parts()
			tl_update()
		}

		with (newtemp)
			instance_destroy()
	}
	else
	{
		if (history_redo)
			roottl = save_id_find(history_data.tl_save_id)
		else
			roottl = tl_edit

		if (roottl = null || roottl.has_temp || roottl.part_root != null ||
			roottl.type >= e_temp_type.amount || type_is_templated(roottl.type))
			return 0

		if (!history_redo)
		{
			hobj = history_set(action_tl_create_temp)
			hobj.tl_save_id = roottl.save_id
		}

		// Create template
		newtemp = new_obj(obj_template)
		with (roottl)
			tl_create_temp_copy(newtemp)

		// Move runtime ownership
		if (roottl.type = e_tl_type.BLOCK)
		{
			newtemp.block_vbuffer = roottl.block_vbuffer
			roottl.block_vbuffer = null
		}
		else if (roottl.type = e_tl_type.SPECIAL_BLOCK)
			with (roottl)
				tl_create_temp_move_model(newtemp)
		
		with (roottl)
			tl_create_temp_move_pattern_update(newtemp)

		// Link the timeline hierarchy
		with (obj_timeline)
		{
			if (temp != roottl)
				continue

			id.temp = newtemp
			has_temp = true
		}

		with (newtemp)
		{
			if (type = e_temp_type.SPECIAL_BLOCK)
				temp_update_model_shape()
			temp_update_rot_point()
			temp_update_display_name()
			temp_add_lists()
			temp_select_edit(false)
		}

		with (roottl)
			tl_update()

		if (!history_redo)
			hobj.temp_save_id = newtemp.save_id
	}

	tl_update_list()
	tl_update_matrix()
	app_update_tl_edit()
	project_update_counts()
	lib_preview.update = true
}

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

function tl_create_temp_move_model(to)
{
	to.model_file = model_file
	to.model_texture_name_map = model_texture_name_map
	to.model_texture_material_name_map = model_texture_material_name_map
	to.model_texture_normal_name_map = model_texture_normal_name_map
	to.model_shape_texture_name_map = model_shape_texture_name_map
	to.model_shape_texture_material_name_map = model_shape_texture_material_name_map
	to.model_shape_texture_normal_name_map = model_shape_texture_normal_name_map
	to.model_hide_list = model_hide_list
	to.model_shape_hide_list = model_shape_hide_list
	to.model_color_name_map = model_color_name_map
	to.model_color_map = model_color_map
	to.model_shape_vbuffer_map = model_shape_vbuffer_map
	to.model_shape_alpha_map = model_shape_alpha_map
	to.pattern_skin = pattern_skin

	model_file = null
	model_texture_name_map = null
	model_texture_material_name_map = null
	model_texture_normal_name_map = null
	model_shape_texture_name_map = null
	model_shape_texture_material_name_map = null
	model_shape_texture_normal_name_map = null
	model_hide_list = null
	model_shape_hide_list = null
	model_color_name_map = null
	model_color_map = null
	model_shape_vbuffer_map = null
	model_shape_alpha_map = null
	pattern_skin = null
}

function tl_create_temp_move_pattern_update(to)
{
	if (is_array(pattern_update))
	{
		for (var i = 0; i < array_length(pattern_update); i++)
			if (pattern_update[i] = id)
				pattern_update[i] = to
	}
	else if (pattern_update = id)
		pattern_update = to
}

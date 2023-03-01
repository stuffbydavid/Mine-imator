/// project_load_legacy_template()

function project_load_legacy_template()
{
	with (new_obj(obj_template))
	{
		loaded = true
		load_id = buffer_read_int()
		save_id_map[?load_id] = load_id
		
		var typename = buffer_read_string_int();
		type = ds_list_find_index(temp_type_name_list, typename)
		
		name = buffer_read_string_int()
		if (load_format = e_project.FORMAT_100_DEMO_2)
			/*count = */buffer_read_int()
		
		model_tex = project_load_legacy_save_id()
		if (load_format >= e_project.FORMAT_100_DEBUG)
			legacy_model_name = buffer_read_string_int()
		else 
			legacy_model_name = project_load_legacy_model_name(buffer_read_int())
		legacy_bodypart_id = buffer_read_int()
		
		// Find new model name and state
		if (type = e_temp_type.CHARACTER || type = e_temp_type.SPECIAL_BLOCK || type = e_temp_type.BODYPART)
		{
			var modelmap = legacy_model_name_map[?legacy_model_name];
			if (ds_map_valid(modelmap))
			{
				model_name = modelmap[?"name"]
				if (!is_undefined(modelmap[?"state"]))
					model_state = string_get_state_vars(modelmap[?"state"])
				else
					model_state = array()
			}
			else
				log("Could not convert model ", legacy_model_name)
		}
		
		// Find new model part name
		if (type = e_temp_type.BODYPART)
		{
			var modelpartlist = legacy_model_part_map[?model_name];
			if (ds_list_valid(modelpartlist) && legacy_bodypart_id < ds_list_size(modelpartlist))
				model_part_name = modelpartlist[|legacy_bodypart_id]
			else
				log("Could not convert model part of ", model_name, legacy_bodypart_id)
		}
		
		item_tex = project_load_legacy_save_id()
		if (load_format >= e_project.FORMAT_100_DEBUG)
			legacy_item_sheet = buffer_read_byte()
		item_slot = buffer_read_int()
		item_3d = buffer_read_byte()
		item_face_camera = buffer_read_byte()
		item_bounce = buffer_read_byte()
		
		// Read legacy block
		var bid, bdata;
		bid = buffer_read_short()
		bdata = buffer_read_byte()
		if (legacy_block_set[bid])
		{
			var block = legacy_block_obj[bid, bdata];
			if (block != null)
			{
				block_name = block.name
				block_state = block_get_state_id_state_vars(block, legacy_block_state_id[bid, bdata])
			}
		}
		
		block_tex = project_load_legacy_save_id()
		
		scenery = buffer_read_int()
		if (scenery = 0)
			scenery = null
		
		block_repeat_enable = buffer_read_byte()
		block_repeat[X] = buffer_read_int()
		block_repeat[Y] = buffer_read_int()
		block_repeat[Z] = buffer_read_int()
		
		shape_tex = buffer_read_int()
		if (shape_tex = 0)
			shape_tex = null
		if (load_format >= e_project.FORMAT_100_DEBUG)
		{
			shape_tex_mapped = buffer_read_byte()
			shape_tex_hoffset = buffer_read_double()
			shape_tex_voffset = buffer_read_double()
		}
		shape_tex_hrepeat = buffer_read_double()
		shape_tex_vrepeat = buffer_read_double()
		shape_tex_hmirror = buffer_read_byte()
		shape_tex_vmirror = buffer_read_byte()
		if (load_format >= e_project.FORMAT_100_DEBUG)
			shape_closed = buffer_read_byte()
		shape_invert = buffer_read_byte()
		shape_detail = buffer_read_int()
		if (load_format >= e_project.FORMAT_100_DEBUG)
			shape_face_camera = buffer_read_byte()
		
		text_font = project_load_legacy_save_id()
		if (text_font = "root")
			text_font = null
		if (load_format < e_project.FORMAT_100_DEMO_4)
		{
			buffer_read_string_int() // system font name
			buffer_read_byte() // system font bold
			buffer_read_byte() // system font italic
		}
		text_face_camera = buffer_read_byte()
		
		if (type = e_temp_type.PARTICLE_SPAWNER)
			project_load_legacy_particles()
		
		if (temp_creator = app)
			sortlist_add(app.lib_list, id)
	}
}

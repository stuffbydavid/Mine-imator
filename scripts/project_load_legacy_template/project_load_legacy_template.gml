/// project_load_legacy_template()

with (new(obj_template))
{
	loaded = true
	load_id = buffer_read_int()
	save_id_map[?load_id] = load_id
	
	type = buffer_read_string_int()
	name = buffer_read_string_int()
	if (load_format = e_project.FORMAT_100_DEMO_2)
		/*count = */buffer_read_int()

	skin = project_load_legacy_save_id()
	if (load_format >= e_project.FORMAT_100_DEBUG)
		legacy_model_name = buffer_read_string_int()
	else 
		legacy_model_name = project_load_legacy_model_name(buffer_read_int())
	legacy_bodypart_id = buffer_read_int()
	
	// Find new model name and state
	var modelmap = legacy_model_name_map[?legacy_model_name];
	if (!is_undefined(modelmap))
	{
		model_name = modelmap[?"name"]
		if (!is_undefined(modelmap[?"state"]))
			model_state = modelmap[?"state"]
		else
			model_state = ""
	}
	else
		log("Could not convert model ", legacy_model_name)
	
	// Find new model part name
	var modelpartlist = legacy_model_part_map[?model_name];
	if (!is_undefined(modelpartlist))
		model_part_name = modelpartlist[|legacy_bodypart_id]
	else
		log("Could not convert model part of ", model_name, legacy_bodypart_id)
		
	item_tex = project_load_legacy_save_id()
	if (load_format >= e_project.FORMAT_100_DEBUG)
		legacy_item_sheet = buffer_read_byte()
	item_slot = buffer_read_int()
	item_3d = buffer_read_byte()
	item_face_camera = buffer_read_byte()
	item_bounce = buffer_read_byte()

	var bid, bdata, block;
	bid = buffer_read_short()
	bdata = buffer_read_byte()
	block = mc_assets.block_legacy_id_map[?bid]
	if (!is_undefined(block))
	{
		block_name = block.name
		block_state = block.legacy_data_state[bdata]
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

	if (type = "particles")
		project_load_legacy_particles()
		
	if (temp_creator = app)
		sortlist_add(app.lib_list, id)
}

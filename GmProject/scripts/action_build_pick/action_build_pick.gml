function action_build_pick()
{
	if (!app.place_build || app.place_target_tl = null || !instance_exists(app.place_target_tl))
		return false

	var target, pickname, pickstate, pickspblock;
	target = app.place_target_tl
	pickname = ""
	pickstate = []
	pickspblock = false

	// Pick the special block owning the rendered part
	if (target.type = e_tl_type.MODEL_PART && target.part_of != null)
		target = target.part_of
	
	if (type_is_structure(target.type))
	{
		if (app.place_block_pos = null)
			return false

		// Block data is needed from source file
		with (target)
			if (!tl_scenery_load_blocks())
				return false

		var data, block, stateid;
		with (target)
			data = block_meshes_get_block(app.place_block_pos[X], app.place_block_pos[Y], app.place_block_pos[Z])
		
		block = block_objs[data[0]]
		stateid = data[1]
		
		if (block = null)
			return false

		if (block.tl_mesh)
			stateid = block_set_state_id_value(block, stateid, "visible", "true")

		pickname = block.name
		pickstate = block_get_state_id_state_vars(block, stateid)

		// Match the build list's special block entry
		if (block.timeline && block.tl_model_name != "" && !block.tl_model_double)
		{
			pickname = block.tl_model_name
			pickspblock = true
			
			if (block.tl_has_model_state)
			{
				pickstate = []
				if (block.tl_model_state_amount = 0)
					pickstate = array_copy_1d(block.tl_model_state)

				for (var i = 0; i < block.tl_model_state_amount; i++)
				{
					var state = block.tl_model_state[i];
					if (array_contains(state.state_id, stateid))
					{
						pickstate = array_copy_1d(state.value)
						break
					}
				}
			}
		}
	}
	else if (target.type = e_tl_type.BLOCK)
	{
		pickname = target.temp.block_name
		pickstate = array_copy_1d(target.temp.block_state)
	}
	else if (target.type = e_tl_type.SPECIAL_BLOCK)
	{
		pickname = target.temp.model_name
		pickstate = array_copy_1d(target.temp.model_state)
		pickspblock = true
	}
	else
		return false

	// Find entry in build list and scroll to it
	var picker = app.build_tool.build_picker;
	for (var i = 0; i < ds_list_size(picker.list); i++)
	{
		var value = picker.list[|i];
		if (value[0] != pickspblock || value[1] != pickname)
			continue

		if (picker.search_tbx.text != "")
		{
			picker.search_tbx.text = ""
			picker.search = false
			sortlist_update(picker)
		}

		action_build_select(value, pickstate)

		asset_picker_view(app.build_tool.build_picker, value, false)

		// Focus on the picked block in world space
		var focuspos = matrix_position(target.matrix);
		if (type_is_structure(target.type))
			focuspos = point3D_mul_matrix(vec3_mul(vec3_add(app.place_block_pos, 0.5), block_size), target.matrix_render)

		with (app)
			camera_work_set_focus(focuspos)
		
		return true
	}

	return false
}

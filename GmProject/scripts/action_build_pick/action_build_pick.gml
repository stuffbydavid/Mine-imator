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

		var res, data, block, stateid, needblocks;
		res = null
		needblocks = false
		
		if (target.type = e_tl_type.SCENERY && target.temp != null)
			res = target.temp.scenery
		
		if (res != null && !res.ready)
			return false

		// Check for missing block palette/grid
		if (res != null)
		{
			needblocks = (array_length(res.block_meshes) = 0)
			for (var s = 0; s < array_length(res.block_meshes); s++)
			{
				var mesh = res.block_meshes[s];
				if (mesh != null && (mesh.block_palette_buffer = null || mesh.block_grid_buffer = null))
					needblocks = true
			}
		}

		// Load blocks only from source Schematic with no mesh generation
		if (needblocks)
		{
			with (res)
			{
				if (!res_load_scenery_file(app.project_folder + "/" + filename, true))
				{
					error("error/load_schematic")
					return false
				}
			}
		}

		with (target)
			data = block_meshes_get_block(app.place_block_pos[X], app.place_block_pos[Y], app.place_block_pos[Z])
		
		block = block_objs[data[0]]
		stateid = data[1]
		
		if (block = null)
			return false

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
	var list = app.build_tool.build_list;
	for (var i = 0; i < ds_list_size(list.list); i++)
	{
		var value = list.list[|i];
		if (value[0] != pickspblock || value[1] != pickname)
			continue

		if (list.search_tbx.text != "")
		{
			list.search_tbx.text = ""
			list.search = false
			sortlist_update(list)
		}

		action_build_select(value)
		
		with (app.build_settings)
		{
			if (pickspblock)
			{
				model_state = pickstate
				temp_update_model()
				temp_update_model_shape()
			}
			else
			{
				block_state = pickstate
				temp_update_block()
				temp_update_rot_point()
			}
		}

		sortlist_view(list, value, false)
		
		return true
	}

	return false
}

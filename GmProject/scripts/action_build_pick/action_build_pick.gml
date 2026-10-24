function action_build_pick()
{
	if (!app.place_build || app.place_target_tl = null || !instance_exists(app.place_target_tl))
		return false

	var target, special, pickname, pickstate;
	target = app.place_target_tl
	special = false
	pickname = ""
	pickstate = []

	// Pick the special block owning the rendered part
	if (target.type = e_tl_type.MODEL_PART && target.part_of != null)
		target = target.part_of

	if (target.type = e_tl_type.SPECIAL_BLOCK)
	{
		special = true
		pickname = target.temp.model_name
		pickstate = array_copy_1d(target.temp.model_state)
	}
	else if (target.type = e_tl_type.BLOCK)
	{
		pickname = target.temp.block_name
		pickstate = array_copy_1d(target.temp.block_state)
	}
	else if (target.type = e_tl_type.SCENERY)
	{
		if (app.build_box_render != app.build_box)
			return false

		var data, block, stateid;
		with (target)
			data = block_meshes_get_block(matrix_position(app.build_box_matrix))
		
		block = block_objs[data[0]]
		stateid = data[1]
		
		if (block = null)
			return false

		pickname = block.name
		pickstate = block_get_state_id_state_vars(block, stateid)

		// Match the build list's special-block entry
		if (block.timeline && block.tl_model_name != "" && !block.tl_model_double)
		{
			special = true
			pickname = block.tl_model_name
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
	else
		return false

	// Find list entry
	var list = app.build_tool.build_list;
	for (var i = 0; i < ds_list_size(list.list); i++)
	{
		var value = list.list[|i];
		if (value[0] != special || value[1] != pickname)
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
			if (special)
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

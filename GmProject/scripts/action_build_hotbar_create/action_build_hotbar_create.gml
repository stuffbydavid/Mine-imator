/// @desc Creates a hotbar or duplicates the selected hotbar.
/// @arg [duplicate]

function action_build_hotbar_create(duplicate = false)
{
	var hobj, list, hotbar;
	list = build_hotbars.list

	if (history_undo || history_redo)
		hobj = history_data
	else
	{
		var script = action_build_hotbar_create;
		if (duplicate)
			script = action_build_hotbar_duplicate
		
		hobj = history_set(script)
		hobj.hotbar_index = build_hotbars.selected + 1
		hobj.hotbar_selected = build_hotbars.selected
		hobj.hotbar_slot = build_hotbar_slot
		hobj.hotbar_name = text_get("build_hotbars/default_name")
		hobj.hotbar_blocks = []
		
		if (duplicate)
		{
			hotbar = list.list[|build_hotbars.selected]
			hobj.hotbar_name = hotbar.name
			hobj.hotbar_blocks = array_copy_1d(hotbar.blocks)
		}
		else if (build_settings.type = e_temp_type.SPECIAL_BLOCK)
			hobj.hotbar_blocks = [ [ true, build_settings.model_name, array_copy_1d(build_settings.model_state) ] ]
		else
			hobj.hotbar_blocks = [ [ false, build_settings.block_name, array_copy_1d(build_settings.block_state) ] ]
	}

	if (history_undo)
	{
		hotbar = list.list[|hobj.hotbar_index]
		hobj.hotbar_name = hotbar.name
		hobj.hotbar_blocks = array_copy_1d(hotbar.blocks)
		
		ds_list_delete(list.list, hobj.hotbar_index)
		
		with (hotbar)
			instance_destroy()
		
		sortlist_update(list)
		
		build_hotbar_slot = hobj.hotbar_slot
		
		action_build_hotbars_list(list.list[|hobj.hotbar_selected])
	}
	else
	{
		hotbar = new_obj(obj_build_hotbar)
		hotbar.name = hobj.hotbar_name
		hotbar.blocks = []
		
		for (var i = 0; i < array_length(hobj.hotbar_blocks); i++)
		{
			var block = hobj.hotbar_blocks[i];
			array_add(hotbar.blocks, [ block[0], block[1], array_copy_1d(block[2]) ], false)
		}
		
		sortlist_add(list, hotbar, hobj.hotbar_index)
		sortlist_update(list)
		
		build_hotbar_slot = 0
		
		action_build_hotbars_list(hotbar)
	}

	sortlist_view(list, list.list[|build_hotbars.selected])
}

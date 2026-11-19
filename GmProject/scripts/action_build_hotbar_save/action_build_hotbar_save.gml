/// @desc Copies the current hotbar to an index in the unsorted list.
/// @arg [index]

function action_build_hotbar_save(index = -1)
{
	var hobj, list, hotbar, blocks;
	list = build_hotbars.list
	
	if (history_undo || history_redo)
		hobj = history_data
	else
	{
		if (index < 0 || index > 8 || index = build_hotbars.selected)
			return 0

		hotbar = list.list[|build_hotbars.selected]
		
		hobj = history_set(action_build_hotbar_save)
		hobj.hotbar_index = index
		hobj.hotbar_count = ds_list_size(list.list)
		hobj.hotbar_selected = build_hotbars.selected
		hobj.hotbar_slot = build_hotbar_slot
		hobj.hotbar_new_blocks = array_copy_1d(hotbar.blocks)
		hobj.hotbar_old_blocks = []
		
		if (index < hobj.hotbar_count)
		{
			hotbar = list.list[|index]
			hobj.hotbar_old_blocks = array_copy_1d(hotbar.blocks)
		}
	}

	if (history_undo)
	{
		// Remove the hotbars added to reach the requested index
		while (ds_list_size(list.list) > hobj.hotbar_count)
		{
			var last = ds_list_size(list.list) - 1;
			hotbar = list.list[|last]
			ds_list_delete(list.list, last)
			with (hotbar)
				instance_destroy()
		}
		
		blocks = hobj.hotbar_old_blocks
	}
	else
	{
		// Fill missing indices with empty numbered hotbars
		while (ds_list_size(list.list) <= hobj.hotbar_index)
		{
			hotbar = new_obj(obj_build_hotbar)
			hotbar.name = text_get("build_hotbars/default_name") + " " + string(ds_list_size(list.list) + 1)
			hotbar.blocks = []
			
			sortlist_add(list, hotbar)
		}
		
		blocks = hobj.hotbar_new_blocks
	}

	// Copy slot states independently of the source and history
	if (hobj.hotbar_index < ds_list_size(list.list))
	{
		hotbar = list.list[|hobj.hotbar_index]
		hotbar.blocks = []
		
		for (var i = 0; i < array_length(blocks); i++)
		{
			var block = blocks[i];
			array_add(hotbar.blocks, [ block[0], block[1], array_copy_1d(block[2]) ], false)
		}
	}

	sortlist_update(list)
	
	build_hotbar_slot = hobj.hotbar_slot
	action_build_hotbars_list(list.list[|hobj.hotbar_selected])
	
	window_focus = string(view_main)
}

/// @desc Removes the selected hotbar.

function action_build_hotbar_remove()
{
	var hobj, list, hotbar;
	list = build_hotbars.list
	
	if (history_undo || history_redo)
		hobj = history_data
	else
	{
		if (ds_list_size(list.list) <= 1)
			return 0

		hobj = history_set(action_build_hotbar_remove)
		hobj.hotbar_index = build_hotbars.selected
		hobj.hotbar_slot = build_hotbar_slot
	}

	if (history_undo)
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
		
		build_hotbar_slot = hobj.hotbar_slot
		
		action_build_hotbars_list(hotbar)
	}
	else
	{
		hotbar = list.list[|hobj.hotbar_index]
		hobj.hotbar_name = hotbar.name
		hobj.hotbar_blocks = array_copy_1d(hotbar.blocks)
		
		ds_list_delete(list.list, hobj.hotbar_index)
		with (hotbar)
			instance_destroy()
		
		sortlist_update(list)
		
		build_hotbar_slot = 0
		
		action_build_hotbars_list(list.list[|min(hobj.hotbar_index, ds_list_size(list.list) - 1)])
	}

	sortlist_view(list, list.list[|build_hotbars.selected])
}

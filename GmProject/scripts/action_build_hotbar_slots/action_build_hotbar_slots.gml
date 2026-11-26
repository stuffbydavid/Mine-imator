/// @desc Adds an empty slot or removes the selected slot.

function action_build_hotbar_slots(add = true)
{
	var hobj, hotbar, blocks;
	if (history_undo || history_redo)
		hobj = history_data
	else
	{
		if (!add && array_length(build_hotbar_current.blocks) <= 1)
			return 0

		hobj = history_set(action_build_hotbar_slots)
		hobj.hotbar_index = build_hotbars.selected
		hobj.hotbar_slot = build_hotbar_slot
		hobj.hotbar_old_blocks = array_copy_1d(build_hotbar_current.blocks)
		hobj.hotbar_new_blocks = []

		for (var i = 0; i < array_length(build_hotbar_current.blocks); i++)
			if (add || i != build_hotbar_slot)
				array_add(hobj.hotbar_new_blocks, build_hotbar_current.blocks[i], false)

		if (add)
		{
			array_add(hobj.hotbar_new_blocks, [ false, "", [] ], false)
			hobj.hotbar_new_slot = array_length(hobj.hotbar_new_blocks) - 1
		}
		else
			hobj.hotbar_new_slot = min(build_hotbar_slot, array_length(hobj.hotbar_new_blocks) - 1)
	}

	if (history_undo)
	{
		blocks = hobj.hotbar_old_blocks
		build_hotbar_slot = hobj.hotbar_slot
	}
	else
	{
		blocks = hobj.hotbar_new_blocks
		build_hotbar_slot = hobj.hotbar_new_slot
	}

	// Keep the stored states independent of history
	hotbar = build_hotbars.list.list[|hobj.hotbar_index]
	hotbar.blocks = []
	for (var i = 0; i < array_length(blocks); i++)
	{
		var block = blocks[i];
		array_add(hotbar.blocks, [ block[0], block[1], array_copy_1d(block[2]) ], false)
	}

	sortlist_update(build_hotbars.list)
	action_build_hotbars_list(hotbar)
	
	window_focus = string(view_main)
}

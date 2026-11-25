/// @desc Adds a slot with the current block or removes the selected slot.
/// @arg [add]

function action_build_hotbar_slots(add = true)
{
	var hobj, hotbar, blocks;
	if (history_undo || history_redo)
		hobj = history_data
	else
	{
		hotbar = build_hotbars.list.list[|build_hotbars.selected]
		if (!add && array_length(hotbar.blocks) <= 1)
			return 0

		hobj = history_set(action_build_hotbar_slots)
		hobj.hotbar_index = build_hotbars.selected
		hobj.hotbar_slot = build_hotbar_slot
		hobj.hotbar_old_blocks = array_copy_1d(hotbar.blocks)
		hobj.hotbar_new_blocks = []

		for (var i = 0; i < array_length(hotbar.blocks); i++)
			if (add || i != build_hotbar_slot)
				array_add(hobj.hotbar_new_blocks, hotbar.blocks[i], false)

		if (add)
		{
			var block;
			if (build_settings.type = e_temp_type.SPECIAL_BLOCK)
				block = [ true, build_settings.model_name, array_copy_1d(build_settings.model_state) ]
			else
				block = [ false, build_settings.block_name, array_copy_1d(build_settings.block_state) ]

			array_add(hobj.hotbar_new_blocks, block, false)
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

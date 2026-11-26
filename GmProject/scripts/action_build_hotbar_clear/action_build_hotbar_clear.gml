/// @desc Clears a hotbar slot without removing its cell.

function action_build_hotbar_clear(slot)
{
	var hobj, hotbar, block;
	if (history_undo || history_redo)
		hobj = history_data
	else
	{
		block = build_hotbar_current.blocks[slot]
		if (block[1] = "")
			return 0

		hobj = history_set(action_build_hotbar_clear)
		hobj.hotbar_index = build_hotbars.selected
		hobj.hotbar_slot = slot
		hobj.hotbar_selected_slot = build_hotbar_slot
		hobj.hotbar_block = [ block[0], block[1], array_copy_1d(block[2]) ]
	}

	block = [ false, "", [] ]
	if (history_undo)
		block = hobj.hotbar_block

	hotbar = build_hotbars.list.list[|hobj.hotbar_index]
	hotbar.blocks[hobj.hotbar_slot] = [ block[0], block[1], array_copy_1d(block[2]) ]
	build_hotbar_slot = hobj.hotbar_selected_slot
	action_build_hotbars_list(hotbar)

	window_focus = string(view_main)
	app_mouse_clear()
}

/// @desc Adds a picked block and state to the first empty hotbar slot.

function action_build_hotbar_add(block = null)
{
	var hobj;
	if (history_undo || history_redo)
		hobj = history_data
	else
	{
		var slot = -1;
		for (var i = 0; i < array_length(build_hotbar_current.blocks); i++)
		{
			if (build_hotbar_current.blocks[i][1] = "")
			{
				slot = i
				break
			}
		}

		if (slot < 0)
			return 0

		hobj = history_set(action_build_hotbar_add)
		hobj.hotbar_index = build_hotbars.selected
		hobj.hotbar_slot = slot
		hobj.hotbar_block = [ block[0], block[1], array_copy_1d(block[2]) ]
	}

	block = hobj.hotbar_block
	if (history_undo)
		block = [ false, "", [] ]

	var hotbar = build_hotbars.list.list[|hobj.hotbar_index];
	hotbar.blocks[hobj.hotbar_slot] = [ block[0], block[1], array_copy_1d(block[2]) ]

	if (place_build && build_hotbars.selected = hobj.hotbar_index && build_hotbar_slot = hobj.hotbar_slot)
		action_build_hotbar_select(build_hotbar_slot)
}

/// @desc Selects a build hotbar slot.

function action_build_hotbar_select(slot)
{
	var blocks, block, picker;
	blocks = build_hotbars.list.list[|build_hotbars.selected].blocks
	if (slot < 0 || slot >= array_length(blocks))
		return 0

	block = blocks[slot]
	picker = build_tool.build_picker

	for (var b = 0; b < ds_list_size(picker.list); b++)
	{
		var value = picker.list[|b];
		if (value[0] != block[0] || value[1] != block[1])
			continue

		build_hotbar_slot = slot
		
		action_build_select(value, block[2])
		
		if (ds_list_find_index(picker.display_list, value) < 0)
		{
			picker.search_tbx.text = ""
			picker.search = false
			
			sortlist_update(picker)
		}
		
		asset_picker_view(picker, value)
		
		window_focus = string(view_main)
		
		app_mouse_clear()
		
		break
	}
}

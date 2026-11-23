/// @desc Stores the current build selection and state in the selected hotbar slot.
/// @arg [value]

function view_build_hotbar_update(value = null)
{
	if (build_hotbars.selected < 0 || build_hotbars.selected >= ds_list_size(build_hotbars.list.list))
		return 0

	var hotbar, special, name, states;
	hotbar = build_hotbars.list.list[|build_hotbars.selected]
	if (build_hotbar_slot < 0 || build_hotbar_slot >= array_length(hotbar.blocks))
		return 0

	special = (build_settings.type = e_temp_type.SPECIAL_BLOCK)
	if (special)
	{
		name = build_settings.model_name
		states = build_settings.model_state
	}
	else
	{
		name = build_settings.block_name
		states = build_settings.block_state
	}

	var block = hotbar.blocks[build_hotbar_slot];
	if (value != null || (block[0] = special && block[1] = name))
		hotbar.blocks[build_hotbar_slot] = [ special, name, array_copy_1d(states) ]
}

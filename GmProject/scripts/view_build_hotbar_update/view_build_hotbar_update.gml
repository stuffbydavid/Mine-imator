/// @desc Stores the current build selection and state in the selected hotbar slot.
/// @arg [value]

function view_build_hotbar_update(value = null)
{
	if (build_hotbar_current = null)
		return 0

	if (build_hotbar_slot < 0 || build_hotbar_slot >= array_length(build_hotbar_current.blocks))
		return 0

	var special, name, states;
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

	var block = build_hotbar_current.blocks[build_hotbar_slot];
	if (value != null || (block[0] = special && block[1] = name))
		build_hotbar_current.blocks[build_hotbar_slot] = [ special, name, array_copy_1d(states) ]
}

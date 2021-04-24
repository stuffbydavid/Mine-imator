/// keybind_restore(keybindID, [group])
/// @arg keybindID
/// @arg [group]

function keybind_restore()
{
	var keybindID, group, obj;
	keybindID = argument[0]
	
	if (argument_count > 1)
		group = argument[1]
	else
		group = false
	
	obj = keybinds_map[?keybindID]
	obj.keybind = obj.keybind_default
	
	if (!group)
	{
		keybinds_update_match()
		settings_save()
	}
}

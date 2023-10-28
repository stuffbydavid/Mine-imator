/// keybind_restore(keybindID, [group])
/// @arg keybindID
/// @arg [group]

function keybind_restore(keybindID, group = false)
{
	var obj = keybinds[keybindID]
	obj.keybind = obj.keybind_default
	
	if (!group)
	{
		keybinds_update_match()
		settings_save()
	}
}

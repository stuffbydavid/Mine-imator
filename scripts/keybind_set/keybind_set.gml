/// keybind_set(keybindID, keybind)
/// @arg keybindID
/// @arg keybind

function keybind_set(keybindID, keybind)
{
	var obj = keybinds_map[?keybindID];
	obj.keybind = keybind
	
	keybinds_update_match()
	settings_save()
}

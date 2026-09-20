/// keybind_clear(keybindID)
/// @arg keybindID

function keybind_clear(keybindID)
{
	var obj = keybinds[keybindID];
	obj.keybind = keybind_new(vk_nokey)
	
	keybinds_update_match()
	settings_save()
}

function keybind_set(keybindid, keybind)
{
	var obj = keybinds[keybindid];
	obj.keybind = keybind
	
	keybinds_update_match()
	settings_save()
}

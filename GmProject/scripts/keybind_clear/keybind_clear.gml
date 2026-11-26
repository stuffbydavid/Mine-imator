function keybind_clear(keybindid)
{
	var obj = keybinds[keybindid];
	obj.keybind = keybind_new(vk_nokey)
	
	keybinds_update_match()
	settings_save()
}

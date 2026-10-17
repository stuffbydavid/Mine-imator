function keybind_restore(keybindid, group = false)
{
	var obj = keybinds[keybindid];
	obj.keybind = obj.keybind_default
	
	if (!group)
	{
		keybinds_update_match()
		settings_save()
	}
}

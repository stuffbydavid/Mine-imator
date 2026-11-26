function keybind_register(name, keybindid, keybind, navigation = false)
{
	var obj = new_obj(obj_keybind);
	obj.name = name
	obj.keybind_id = keybindid
	obj.keybind_default = keybind
	obj.keybind = keybind
	obj.navigation = navigation
	
	keybinds[keybindid] = obj
}

/// keybind_register(name, keybindID, keybind, [navigation, [windowcheck]])
/// @arg name
/// @arg keybindID
/// @arg keybind
/// @arg [navigation
/// @arg [windowcheck]]

function keybind_register(name, keybindID, keybind, navigation = false, windowcheck = true)
{
	var obj = new_obj(obj_keybind);
	obj.name = name
	obj.keybind_id = keybindID
	obj.keybind_default = keybind
	obj.keybind = keybind
	obj.navigation = navigation
	obj.windowcheck = windowcheck
	
	keybinds[keybindID] = obj
}

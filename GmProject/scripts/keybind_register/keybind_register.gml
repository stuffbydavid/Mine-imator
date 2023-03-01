/// keybind_register(name, keybindID, keybind, [navigation])
/// @arg name
/// @arg keybindID
/// @arg keybind
/// @arg [navigation]

function keybind_register(name, keybindID, keybind, navigation = false)
{
	var obj = new_obj(obj_keybind);
	obj.name = name
	obj.keybind_id = keybindID
	obj.keybind_default = keybind
	obj.keybind = keybind
	obj.navigation = navigation
	
	keybinds[keybindID] = obj
}

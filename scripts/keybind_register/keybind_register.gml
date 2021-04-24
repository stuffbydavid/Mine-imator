/// keybind_register(name, keybindID, keybind)
/// @arg name
/// @arg keybindID
/// @arg keybind

function keybind_register(name, keybindID, keybind)
{
	var obj = new_obj(obj_keybind);
	obj.name = name
	obj.keybind_id = keybindID
	obj.keybind_default = keybind
	obj.keybind = keybind
	
	keybinds_map[?keybindID] = obj
}

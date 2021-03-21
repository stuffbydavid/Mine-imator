/// keybind_register(name, keybindID, keybind)
/// @arg name
/// @arg keybindID
/// @arg keybind

var name, keybindID, keybind, obj;
name = argument0
keybindID = argument1
keybind = argument2

obj = new(obj_keybind)
obj.name = name
obj.keybind_id = keybindID
obj.keybind_default = keybind
obj.keybind = keybind

keybinds_map[?keybindID] = obj

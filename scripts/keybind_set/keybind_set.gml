/// keybind_set(keybindID, keybind)
/// @arg keybindID
/// @arg keybind

var keybindID, keybind, obj;
keybindID = argument0
keybind = argument1
obj = keybinds_map[?keybindID]

obj.keybind = keybind

keybinds_update_match()
settings_save()

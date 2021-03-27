/// shortcut_bar_add(keybind, mouse, text)
/// @arg keybind
/// @arg mouse
/// @arg text

ds_list_add(app.shortcut_bar_list, [argument0, argument1, text_get("shortcut" + argument2)])

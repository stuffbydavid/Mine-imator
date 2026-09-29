function shortcut_bar_add(keybind, mouse, text)
{
	ds_list_add(app.shortcut_bar_list, [keybind, mouse, text_get("shortcut" + text)])
}

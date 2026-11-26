/// @desc Sets a tooltip shortcut from a keybind ID or key array.

function tip_set_keybind(keybindid)
{
	if (is_array(keybindid))
		tip_keybind = keybindid
	else
		tip_keybind = keybinds[keybindid].keybind
}

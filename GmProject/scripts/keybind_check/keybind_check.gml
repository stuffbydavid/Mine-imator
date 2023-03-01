/// keybind_check(keybindobj, checkscript)
/// @arg keybindobj
/// @arg checkscript

function keybind_check(keybindobj, checkscript)
{
	var keybind, scriptres, charcheck;
	keybind = keybindobj.keybind
	switch (checkscript)
	{
		case "keyboard_check": scriptres = keyboard_check(keybind[e_keybind_key.CHAR]) break
		case "keyboard_check_pressed": scriptres = keyboard_check_pressed(keybind[e_keybind_key.CHAR]) break
		case "keyboard_check_released": scriptres = keyboard_check_released(keybind[e_keybind_key.CHAR]) break
	}
	charcheck = (keybind[e_keybind_key.CHAR] = null || scriptres)
	
	if (checkscript = "keyboard_check")
	{
		keybindobj.check_ctrl = (keyboard_check(vk_control) = keybind[e_keybind_key.CTRL]) || (keybindobj.navigation && !keybind[e_keybind_key.CTRL])
		keybindobj.check_shift = (keyboard_check(vk_shift) = keybind[e_keybind_key.SHIFT]) || (keybindobj.navigation && !keybind[e_keybind_key.SHIFT])
		keybindobj.check_alt = (keyboard_check(vk_alt) = keybind[e_keybind_key.ALT]) || (keybindobj.navigation && !keybind[e_keybind_key.ALT])
	}
	
	return (charcheck && keybindobj.check_ctrl && keybindobj.check_shift && keybindobj.check_alt)
}

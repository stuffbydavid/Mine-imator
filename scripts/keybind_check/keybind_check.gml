/// keybind_check(keybindarray)
/// @arg keybind

var keybind, charcheck, ctrlcheck, shiftcheck, altcheck;
keybind = argument0

charcheck = (keybind[e_keybind_key.CHAR] = null || keyboard_check(keybind[e_keybind_key.CHAR]))
ctrlcheck = (keyboard_check(vk_control) = keybind[e_keybind_key.CTRL])
shiftcheck = ((keyboard_check(vk_shift) && keybind[e_keybind_key.SHIFT]) || !keybind[e_keybind_key.SHIFT])
altcheck = ((keyboard_check(vk_alt) && keybind[e_keybind_key.ALT]) || !keybind[e_keybind_key.ALT])

return (charcheck && ctrlcheck && shiftcheck && altcheck)

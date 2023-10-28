/// keybind_new(character, [ctrl, [shift, [alt]]])
/// @arg character
/// @arg ctrl
/// @arg shift
/// @arg alt
/// @desc Returns a keybind array

function keybind_new(char, ctrl = false, shift = false, alt = false)
{
	if (is_string(char))
		char = ord(char)
	
	return [char, ctrl, shift, alt]
}

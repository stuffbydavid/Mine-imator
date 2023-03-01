/// keybind_new(character, [ctrl, [shift, [alt]]])
/// @arg character
/// @arg ctrl
/// @arg shift
/// @arg alt
/// @desc Returns a keybind array

function keybind_new()
{
	var char, ctrl, shift, alt;
	char = argument[0]
	
	if (is_string(char))
		char = ord(char)
	
	if (argument_count > 1)
		ctrl = argument[1]
	else
		ctrl = false
	
	if (argument_count > 2)
		shift = argument[2]
	else
		shift = false
	
	if (argument_count > 3)
		alt = argument[3]
	else
		alt = false
	
	return [char, ctrl, shift, alt]
}

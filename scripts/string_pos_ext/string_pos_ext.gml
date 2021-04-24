/// string_pos_ext(substr, str, startpos)
/// @arg substr
/// @arg str
/// @arg startpos

function string_pos_ext(substr, str, startpos)
{
	return string_pos(substr, string_delete(str, 1, startpos)) + startpos
}

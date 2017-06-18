/// key_valid(key)
/// @arg key

var key, keystr;
key = string_upper(argument0)
keystr = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

if (string_length(key) != 8)
	return false
	
for (var c = 0; c < 8; c += 2)
{
	var pos1, pos2;
	pos1 = string_pos(string_char_at(key, c + 1), keystr)
	pos2 = string_pos(string_char_at(key, 8 - c), keystr)
	if (pos1 = 0 || pos2 = 0)
		return false
	if (pos1 != string_length(keystr) + 1 - pos2)
		return false
}

return true

/// @arg string

function hex_to_color(str)
{
	var nstr, hex;
	nstr = string_replace(str, "#", "")
	nstr = string_upper(nstr + string_repeat("0", 6 - string_length(nstr)))
	hex = "0123456789ABCDEF"
	
	return make_color_rgb(string_pos(string_char_at(nstr, 1), hex) * 16 + string_pos(string_char_at(nstr, 2), hex) - 17, 
						  string_pos(string_char_at(nstr, 3), hex) * 16 + string_pos(string_char_at(nstr, 4), hex) - 17, 
						  string_pos(string_char_at(nstr, 5), hex) * 16 + string_pos(string_char_at(nstr, 6), hex) - 17)
}

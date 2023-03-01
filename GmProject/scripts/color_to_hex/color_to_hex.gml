/// color_to_hex(color)
/// @arg color

function color_to_hex(color)
{
	var r, g, b, hex;
	r = color_get_red(color)
	g = color_get_green(color)
	b = color_get_blue(color)
	hex = "0123456789ABCDEF"
	
	return string_char_at(hex, (r div 16) + 1) + string_char_at(hex, (r mod 16) + 1) +
		   string_char_at(hex, (g div 16) + 1) + string_char_at(hex, (g mod 16) + 1) +
		   string_char_at(hex, (b div 16) + 1) + string_char_at(hex, (b mod 16) + 1)
}

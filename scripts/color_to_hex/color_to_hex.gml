/// color_to_hex(color)
/// @arg color

var r, g, b, hex;
r = color_get_red(argument0)
g = color_get_green(argument0)
b = color_get_blue(argument0)
hex = "0123456789ABCDEF"

return string_char_at(hex, (r div 16) + 1) + string_char_at(hex, (r mod 16) + 1) +
       string_char_at(hex, (g div 16) + 1) + string_char_at(hex, (g mod 16) + 1) +
       string_char_at(hex, (b div 16) + 1) + string_char_at(hex, (b mod 16) + 1)

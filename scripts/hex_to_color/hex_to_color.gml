/// hex_to_color(string)
/// @arg string

var str, hex;
str = string_replace(argument0, "#", "")
str = string_upper(str + string_repeat("0", 6 - string_length(argument0)))
hex = "0123456789ABCDEF"

return make_color_rgb(string_pos(string_char_at(str, 1), hex) * 16 + string_pos(string_char_at(str, 2), hex) - 17, 
                      string_pos(string_char_at(str, 3), hex) * 16 + string_pos(string_char_at(str, 4), hex) - 17, 
                      string_pos(string_char_at(str, 5), hex) * 16 + string_pos(string_char_at(str, 6), hex) - 17)

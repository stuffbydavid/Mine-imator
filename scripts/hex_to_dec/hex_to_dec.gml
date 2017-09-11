/// hex_to_dec(value)
/// @arg value

var hex, dec, h, p;
hex = string_upper(argument0)
dec = 0
h = "0123456789ABCDEF"
for (p = 1; p <= string_length(hex); p++)
    dec = dec << 4 | (string_pos(string_char_at(hex, p), h) - 1)

return dec
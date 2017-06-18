/// color_add_value(color, amount)
/// @arg color
/// @arg amount

var h, s, v;
h = color_get_hue(argument0)
s = color_get_saturation(argument0)
v = clamp(color_get_value(argument0) + argument1, 0, 255)

return make_color_hsv(h, s, v)

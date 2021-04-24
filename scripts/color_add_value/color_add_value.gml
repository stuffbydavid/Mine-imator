/// color_add_value(color, amount)
/// @arg color
/// @arg amount

function color_add_value(color, amount)
{
	var h, s, v;
	h = color_get_hue(color)
	s = color_get_saturation(color)
	v = clamp(color_get_value(color) + amount, 0, 255)
	
	return make_color_hsv(h, s, v)
}

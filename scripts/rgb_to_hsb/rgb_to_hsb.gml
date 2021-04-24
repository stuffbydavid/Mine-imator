/// rgb_to_hsb(color)
/// @arg color

function rgb_to_hsb(color)
{
	return make_color_hsv(color_get_red(color), color_get_green(color), color_get_blue(color))
}

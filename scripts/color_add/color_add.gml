/// color_add(color1, color2)
/// @arg color1
/// @arg color2

function color_add(color1, color2)
{
	return make_color_rgb(min(255, color_get_red(color1) + color_get_red(color2)), 
						  min(255, color_get_green(color1) + color_get_green(color2)), 
						  min(255, color_get_blue(color1) + color_get_blue(color2)))
}

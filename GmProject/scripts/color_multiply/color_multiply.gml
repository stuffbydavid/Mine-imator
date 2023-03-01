/// color_multiply(color1, color2)
/// @arg color1
/// @arg color2

function color_multiply(color1, color2)
{
	return make_color_rgb((color_get_red(color1) / 255) * (color_get_red(color2) / 255) * 255, 
						  (color_get_green(color1) / 255) * (color_get_green(color2) / 255) * 255, 
						  (color_get_blue(color1) / 255) * (color_get_blue(color2) / 255) * 255)
}

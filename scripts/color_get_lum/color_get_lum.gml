/// color_get_lum(color)
/// @arg color
/// @desc Returns the luminance of a color

function color_get_lum(color)
{
	return (0.2126 * color_get_red(color)) + (0.7152 * color_get_green(color)) + (0.0722 * color_get_blue(color))
}

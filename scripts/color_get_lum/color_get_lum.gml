/// color_get_lum(color)
/// @arg color
/// @desc Returns the luminance of a color

return (0.2126 * color_get_red(argument0)) + (0.7152 * color_get_green(argument0)) + (0.0722 * color_get_blue(argument0))
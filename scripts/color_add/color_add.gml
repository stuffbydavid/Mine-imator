/// color_add(color1, color2)
/// @arg color1
/// @arg color2

return make_color_rgb(min(255, color_get_red(argument0) + color_get_red(argument1)), 
					  min(255, color_get_green(argument0) + color_get_green(argument1)), 
					  min(255, color_get_blue(argument0) + color_get_blue(argument1)))

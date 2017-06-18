/// color_multiply(color1, color2)
/// @arg color1
/// @arg color2

return make_color_rgb((color_get_red(argument0) / 255) * (color_get_red(argument1) / 255) * 255, 
					  (color_get_green(argument0) / 255) * (color_get_green(argument1) / 255) * 255, 
					  (color_get_blue(argument0) / 255) * (color_get_blue(argument1) / 255) * 255)

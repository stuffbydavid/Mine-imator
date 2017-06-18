/// shader_set_uniform_color(uniform, color, alpha)
/// @arg uniform
/// @arg color
/// @arg alpha

shader_set_uniform_f(argument0, 
				     color_get_red(argument1) / 255, 
				     color_get_green(argument1) / 255, 
				     color_get_blue(argument1) / 255, argument2)

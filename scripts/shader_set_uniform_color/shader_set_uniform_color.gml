/// shader_set_uniform_color(name, color, alpha)
/// @arg name
/// @arg color
/// @arg alpha

function shader_set_uniform_color(name, color, alpha)
{
	shader_set_uniform_f(name, 
						 color_get_red(color) / 255, 
						 color_get_green(color) / 255, 
						 color_get_blue(color) / 255, alpha)
}

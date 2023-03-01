/// shader_set_uniform_color(index, color, alpha)
/// @arg index
/// @arg color
/// @arg alpha

function shader_set_uniform_color(index, color, alpha)
{
	shader_submit_vec4(index, 
					   color_get_red(color) / 255, 
					   color_get_green(color) / 255, 
					   color_get_blue(color) / 255, alpha)
}

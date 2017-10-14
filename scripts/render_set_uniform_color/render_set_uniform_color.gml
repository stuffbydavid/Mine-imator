/// render_set_uniform_color(uniform, color, alpha)
/// @arg uniform
/// @arg color
/// @arg alpha

var name, color, alpha, uniform;
name = argument0
color = argument1
alpha = argument2
uniform = render_shader_obj.uniform_map[?name]

if (!is_undefined(uniform) && uniform > -1)
	shader_set_uniform_color(uniform, color, alpha)
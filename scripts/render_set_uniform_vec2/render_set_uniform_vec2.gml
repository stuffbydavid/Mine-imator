/// render_set_uniform_vec2(name, x, y)
/// @arg name
/// @arg x
/// @arg y
/// @desc Sets a 2-float uniform (if it exists) of the currently selected shader.

var name, xx, yy, uniform;
name = argument0
xx = argument1
yy = argument2
uniform = render_shader_obj.uniform_map[?name]

if (!is_undefined(uniform) && uniform > -1)
	shader_set_uniform_f(uniform, xx, yy)
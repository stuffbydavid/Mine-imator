/// render_set_uniform_int(name, value)
/// @arg name
/// @arg value
/// @desc Sets an integer uniform (if it exists) of the currently selected shader.

var name, val, uniform;
name = argument0
val = argument1
uniform = render_shader_obj.uniform_map[?name]

if (!is_undefined(uniform) && uniform > -1)
{
	if (is_array(val))
		shader_set_uniform_i_array(uniform, val)
	else
		shader_set_uniform_i(uniform, val)
}
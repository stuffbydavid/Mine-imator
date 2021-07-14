/// render_set_uniform(name, value)
/// @arg name
/// @arg value
/// @desc Sets a float uniform (if it exists) of the currently selected shader.

function render_set_uniform(name, val)
{
	if (!render_update_uniform(name, val, false))
		return 0
	
	var uniform = render_shader_obj.uniform_map[?name];
	
	if (!is_undefined(uniform) && uniform > -1)
	{
		if (is_array(val))
			shader_set_uniform_f_array(uniform, val)
		else
			shader_set_uniform_f(uniform, val)
	}
}

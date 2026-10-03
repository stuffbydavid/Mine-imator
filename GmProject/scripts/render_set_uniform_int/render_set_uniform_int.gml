/// @desc Sets an integer uniform (if it exists) of the currently selected shader.

function render_set_uniform_int(name, value)
{
	var uniform = render_shader_obj.uniform_map[?name];
	
	if (!is_undefined(uniform) && uniform > -1)
	{
		if (!is_array(value))
			shader_submit_int(uniform, value)
	}
}

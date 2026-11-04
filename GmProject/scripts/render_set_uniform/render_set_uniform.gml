/// @desc Sets a float uniform (if it exists) of the currently selected shader.

function render_set_uniform(uniformid, value)
{
	var uniform = render_shader_obj.uniform_handle[uniformid];
	
	if (uniform > -1)
	{
		if (is_array(value))
			shader_submit_float_array(uniform, value)
		else
			shader_submit_float(uniform, value)
	}
}

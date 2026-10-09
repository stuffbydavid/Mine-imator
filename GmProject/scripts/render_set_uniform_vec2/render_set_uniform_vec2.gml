/// @desc Sets a 2-float uniform (if it exists) of the currently selected shader.
/// @arg name
/// @arg x
/// @arg y

function render_set_uniform_vec2(uniformid, xx, yy)
{
	var uniform = render_shader_obj.uniform_handle[uniformid];
	
	if (uniform > -1)
		shader_submit_vec2(uniform, xx, yy)
}

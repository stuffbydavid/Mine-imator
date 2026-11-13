/// @desc Sets a 3-float uniform (if it exists) of the currently selected shader.
/// @arg name
/// @arg x
/// @arg y
/// @arg z

function render_set_uniform_vec3(uniformid, xx, yy, zz)
{
	var uniform = render_shader_obj.uniform_handle[uniformid];
	
	if (uniform > -1)
		shader_submit_vec3(uniform, xx, yy, zz)
}

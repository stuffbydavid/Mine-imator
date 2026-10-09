function render_set_uniform_mat4_array(uniformid, value)
{
	var uniform = render_shader_obj.uniform_handle[uniformid];
	
	if (uniform > -1)
		shader_submit_mat4_array(uniform, value)
}

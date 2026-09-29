function render_set_uniform_mat4_array(name, value)
{
	var uniform = render_shader_obj.uniform_map[?name];
	
	if (!is_undefined(uniform) && uniform > -1)
		shader_submit_mat4_array(uniform, value)
}

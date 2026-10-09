function render_set_uniform_color(uniformid, color, alpha)
{
	var uniform = render_shader_obj.uniform_handle[uniformid];
	if (uniform > -1)
		shader_set_uniform_color(uniform, color, alpha)
}

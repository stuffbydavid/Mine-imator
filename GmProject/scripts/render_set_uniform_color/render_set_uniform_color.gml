function render_set_uniform_color(uniformid, color, alpha)
{
	var uniform = render_shader_obj.uniform_handle[uniformid];
	if (uniform > -1)
		shader_submit_vec4(uniform, 
						   color_get_red(color) / 255, 
						   color_get_green(color) / 255, 
						   color_get_blue(color) / 255, alpha)
}

/// scissor_start(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function scissor_start(xx, yy, w, h)
{
	shader_scissor_x = xx
	shader_scissor_y = yy
	shader_scissor_width = w
	shader_scissor_height = h
	shader_scissor_active = true
	
	render_shader_obj = shader_map[?shader_scissor]
	with (render_shader_obj)
	{
		shader_set(shader_scissor)
		shader_scissor_set(shader_scissor_x, shader_scissor_y, shader_scissor_width, shader_scissor_height)
	}
}

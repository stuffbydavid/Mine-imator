/// scissor_done()

function scissor_done()
{
	shader_scissor_active = false
	
	with (render_shader_obj)
		shader_clear()
}

function shader_outline_set(width, height, size)
{
	render_set_uniform_vec2(e_uniform.TEX_SIZE, width, height)
	render_set_uniform(e_uniform.OUTLINE_SIZE, size)
}

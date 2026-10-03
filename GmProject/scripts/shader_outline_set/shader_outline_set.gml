function shader_outline_set(width, height, size)
{
	render_set_uniform_vec2("uTexSize", width, height)
	render_set_uniform("uOutlineSize", size)
}

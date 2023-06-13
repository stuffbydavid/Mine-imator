/// shader_outline_set(width, height)

function shader_outline_set(width, height)
{
	render_set_uniform_vec2("uTexSize", width, height)
}

/// shader_scissor_set(x, y, width, height)
/// @arg x
/// @arg x
/// @arg width
/// @arg height

function shader_scissor_set(xx, yy, w, h)
{
	render_set_uniform("uBox", [xx, yy, w, h])
	render_set_uniform("uScreenSize", [1, 1])
}

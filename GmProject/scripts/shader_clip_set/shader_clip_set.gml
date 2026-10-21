/// @arg x
/// @arg y
/// @arg width
/// @arg height

function shader_clip_set(xx, yy, w, h)
{
	render_set_uniform(e_uniform.BOX, [ xx, yy, w, h ])
	render_set_uniform(e_uniform.SCREEN_SIZE, [ 1, 1 ])
}

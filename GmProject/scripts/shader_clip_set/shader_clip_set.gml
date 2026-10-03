/// @arg x
/// @arg y
/// @arg width
/// @arg height

function shader_clip_set(xx, yy, w, h)
{
	render_set_uniform("uBox", [ xx, yy, w, h ])
	render_set_uniform("uScreenSize", [ 1, 1 ])
}

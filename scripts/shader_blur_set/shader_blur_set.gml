/// shader_blur_set(width, height, radius, xdirection, ydirection)
/// @arg width
/// @arg height
/// @arg radius
/// @arg xdirection
/// @arg ydirection

function shader_blur_set(width, height, radius, xdir, ydir)
{
	render_set_uniform_vec2("uScreenSize", width, height)
	render_set_uniform("uRadius", radius)
	render_set_uniform_vec2("uDirection", xdir, ydir)
}

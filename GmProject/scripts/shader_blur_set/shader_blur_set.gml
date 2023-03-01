/// shader_blur_set(kernel, radius, xdirection, ydirection)
/// @arg kernel
/// @arg radius
/// @arg xdirection
/// @arg ydirection

function shader_blur_set(kernel, radius, xdir, ydir)
{
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
	render_set_uniform("uKernel", kernel)
	render_set_uniform_int("uSamples", array_length(kernel) / 2)
	render_set_uniform("uRadius", radius)
	render_set_uniform_vec2("uDirection", xdir, ydir)
}

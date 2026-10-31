/// @arg kernel
/// @arg radius
/// @arg xdirection
/// @arg ydirection
/// @arg [clampedges]

function shader_blur_set(kernel, radius, xdir, ydir, clampedges = false)
{
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	render_set_uniform(e_uniform.KERNEL, kernel)
	render_set_uniform_int(e_uniform.SAMPLES, array_length(kernel) / 2)
	render_set_uniform(e_uniform.RADIUS, radius)
	render_set_uniform_vec2(e_uniform.DIRECTION, xdir, ydir)
	render_set_uniform_int(e_uniform.CLAMP_EDGES, clampedges ? 1 : 0)
}

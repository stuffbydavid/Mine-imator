/// shader_blur_set(resolution, radius, xdirection, ydirection)
/// @arg resolution
/// @arg radius
/// @arg xdirection
/// @arg ydirection

render_set_uniform("uResolution", argument0)
render_set_uniform("uRadius", argument1)
render_set_uniform_vec2("uDirection", argument2, argument3)
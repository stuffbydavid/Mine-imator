/// shader_blur_set(width, height, radius, xdirection, ydirection)
/// @arg width
/// @arg height
/// @arg radius
/// @arg xdirection
/// @arg ydirection

render_set_uniform_vec2("uScreenSize", argument0, argument1)
render_set_uniform("uRadius", argument2)
render_set_uniform_vec2("uDirection", argument3, argument4)
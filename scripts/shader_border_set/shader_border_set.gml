/// shader_border_set(width, height)
/// @arg width
/// @arg height

var uTexSize = shader_get_uniform(shader_border, "uTexSize");

shader_set(shader_border)

shader_set_uniform_f(uTexSize, argument0, argument1)
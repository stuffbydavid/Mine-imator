/// new_shader_uniform(name)
/// @arg name

var name, uniform;
name = argument0
uniform = shader_get_uniform(shader, name)

if (uniform > -1)
	uniform_map[?name] = uniform
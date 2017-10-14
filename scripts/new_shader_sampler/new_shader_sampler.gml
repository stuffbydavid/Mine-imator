/// new_shader_sampler(name)
/// @arg name

var name, sampler;
name = argument0
sampler = shader_get_sampler_index(shader, name)

if (sampler > -1)
	sampler_map[?name] = sampler
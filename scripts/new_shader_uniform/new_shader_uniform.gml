/// new_shader_uniform(name)
/// @arg name

function new_shader_uniform(name)
{
	var uniform = shader_get_uniform(shader, name);
	
	if (uniform > -1)
		uniform_map[?name] = uniform
}

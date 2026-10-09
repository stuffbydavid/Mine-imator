function new_shader_uniform(uniformid)
{
	uniform_used[uniformid] = true
	uniform_handle[uniformid] = shader_get_uniform(shader, shader_uniform_name_list[uniformid])
}

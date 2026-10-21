/// @desc Refreshes cached uniform and sampler handles after a shader reload

function shader_reload_handles()
{
	sampler_handle = array_create(e_sampler.amount, -1)
	for (var i = 0; i < e_sampler.amount; i++)
		if (sampler_used[i])
			new_shader_sampler(i)
			
	sampler_texture[e_texture_channel.DIFFUSE] = sampler_handle[e_sampler.TEXTURE]
	sampler_texture[e_texture_channel.MATERIAL] = sampler_handle[e_sampler.TEXTURE_MATERIAL]
	sampler_texture[e_texture_channel.NORMAL] = sampler_handle[e_sampler.TEXTURE_NORMAL]
	
	for (var i = 0; i < e_uniform.amount; i++)
		if (uniform_used[i])
			uniform_handle[i] = shader_get_uniform(shader, shader_uniform_name_list[i])
}

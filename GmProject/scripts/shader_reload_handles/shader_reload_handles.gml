/// @desc Refreshes cached uniform and sampler handles after a shader reload

function shader_reload_handles()
{
	for (var i = 0; i < e_uniform.amount; i++)
		if (uniform_used[i])
			uniform_handle[i] = shader_get_uniform(shader, shader_uniform_name_list[i])
	
	ds_map_clear(sampler_map)
	sampler_texture = array_create(e_texture_channel.amount, -1)
	
	for (var i = 0; i < ds_list_size(sampler_name_list); i++)
	{
		var name, sampler;
		name = sampler_name_list[|i]
		sampler = shader_get_sampler_index(shader, name)
		if (sampler < 0)
			continue
		
		sampler_map[?name] = sampler
		gpu_set_tex_mip_filter_ext(sampler, tf_linear)
		
		switch (name)
		{
			case "uTexture": sampler_texture[e_texture_channel.DIFFUSE] = sampler; break
			case "uTextureMaterial": sampler_texture[e_texture_channel.MATERIAL] = sampler; break
			case "uTextureNormal": sampler_texture[e_texture_channel.NORMAL] = sampler; break
		}
	}
}

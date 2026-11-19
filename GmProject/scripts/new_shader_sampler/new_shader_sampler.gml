function new_shader_sampler(samplerid)
{
	var sampler = shader_get_sampler_index(shader, shader_sampler_name_list[samplerid]);
	sampler_handle[samplerid] = sampler
	sampler_used[samplerid] = true
	
	if (sampler > -1)
		gpu_set_tex_mip_filter_ext(sampler, tf_linear)
	
	return sampler
}

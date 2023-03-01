/// new_shader_sampler(name)
/// @arg name

function new_shader_sampler(name)
{
	var sampler = shader_get_sampler_index(shader, name);
	
	if (sampler > -1)
		sampler_map[?name] = sampler
	
	gpu_set_tex_mip_filter_ext(sampler, tf_linear)
}

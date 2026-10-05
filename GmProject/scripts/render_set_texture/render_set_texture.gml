/// @desc Sets the texture of the currently selected shader.
/// @arg texture
/// @arg [channel]

function render_set_texture(tex, channel = e_texture_channel.DIFFUSE)
{
	var sampler, diffuse;
	sampler = render_shader_obj.sampler_texture[channel]
	diffuse = (channel = e_texture_channel.DIFFUSE)
	if (sampler < 0)
		return 0
	
	if (diffuse)
	{
		shader_texture_width = 0
		shader_texture_height = 0
	}
	
	// Set filter
	var mipactive = shader_texture_filter_mipmap ? mip_on : mip_off;
	
	if (gpu_get_texfilter_ext(sampler) != shader_texture_filter_linear)
		gpu_set_texfilter_ext(sampler, shader_texture_filter_linear)
	
	if (gpu_get_tex_mip_enable() != mipactive)
		gpu_set_tex_mip_enable(mipactive)
	
	// Surface
	if (shader_texture_surface)
	{
		if (surface_exists(tex))
		{
			texture_set_stage(sampler, surface_get_texture(tex))
			
			if (diffuse)
			{
				shader_texture_width = surface_get_width(tex)
				shader_texture_height = surface_get_height(tex)
			}
		}
		else
			texture_set_stage(sampler, 0)
	}
	
	// Sprite texture
	else
	{
		tex = render_get_pack_texture(tex)
		
		if (sprite_exists(tex))
		{
			texture_set_stage(sampler, sprite_get_texture(tex, 0))
			
			if (diffuse)
			{
				shader_texture_width = sprite_get_width(tex)
				shader_texture_height = sprite_get_height(tex)
			}
		}
		else
			texture_set_stage(sampler, 0)
	}
	
	if (diffuse)
		render_set_uniform_vec2(e_uniform.TEXTURE_SIZE, shader_texture_width, shader_texture_height)
	
	gpu_set_texrepeat_ext(sampler, true)
}

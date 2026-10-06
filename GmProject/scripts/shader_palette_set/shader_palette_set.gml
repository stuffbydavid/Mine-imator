function shader_palette_set(palette, palettekey)
{
	texture_set_stage(sampler_handle[e_sampler.PALETTE], sprite_get_texture(palette, 0))
	gpu_set_texfilter_ext(sampler_handle[e_sampler.PALETTE], false)
	
	texture_set_stage(sampler_handle[e_sampler.PALETTE_KEY], sprite_get_texture(palettekey, 0))
	gpu_set_texfilter_ext(sampler_handle[e_sampler.PALETTE_KEY], false)
	
	render_set_uniform(e_uniform.PALETTE_SIZE, sprite_get_width(palette))
}

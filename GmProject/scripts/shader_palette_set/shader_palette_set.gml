function shader_palette_set(palette, palettekey)
{
	texture_set_stage(sampler_map[?"uPalette"], sprite_get_texture(palette, 0))
	gpu_set_texfilter_ext(sampler_map[?"uPalette"], false)
	
	texture_set_stage(sampler_map[?"uPaletteKey"], sprite_get_texture(palettekey, 0))
	gpu_set_texfilter_ext(sampler_map[?"uPaletteKey"], false)
	
	render_set_uniform(e_uniform.PALETTE_SIZE, sprite_get_width(palette))
}

/// shader_palette_set(palette, palettekey)
/// @arg palette
/// @arg palettekey

function shader_palette_set(palette, palettekey)
{
	texture_set_stage(sampler_map[?"uPalette"], sprite_get_texture(palette, 0))
	gpu_set_texfilter_ext(sampler_map[?"uPalette"], false)
	
	texture_set_stage(sampler_map[?"uPaletteKey"], sprite_get_texture(palettekey, 0))
	gpu_set_texfilter_ext(sampler_map[?"uPaletteKey"], false)
	
	render_set_uniform("uPaletteSize", sprite_get_width(palette))
}

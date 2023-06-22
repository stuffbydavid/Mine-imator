/// shader_palette_set(palette)
/// @arg palette

function shader_palette_set(palette)
{
	texture_set_stage(sampler_map[?"uPalette"], surface_get_texture(palette))
	gpu_set_texfilter_ext(sampler_map[?"uPalette"], false)
}

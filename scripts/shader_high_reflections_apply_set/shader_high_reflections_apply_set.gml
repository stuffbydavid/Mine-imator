/// shader_high_reflections_apply_set(ssrsurf, materialsurf)
/// @arg ssrsurf
/// @arg materialbuffer

function shader_high_reflections_apply_set(ssrsurf, materialbuffer)
{
	texture_set_stage(sampler_map[?"uReflectionsBuffer"], surface_get_texture(ssrsurf))
	texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(materialbuffer))
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
}

/// shader_high_reflections_apply_set(ssrsurf, materialsurf, diffusesurf)
/// @arg ssrsurf
/// @arg materialbuffer
/// @arg diffusesurf

function shader_high_reflections_apply_set(ssrsurf, materialbuffer, diffusesurf)
{
	texture_set_stage(sampler_map[?"uReflectionsBuffer"], surface_get_texture(ssrsurf))
	texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(materialbuffer))
	texture_set_stage(sampler_map[?"uDiffuseBuffer"], surface_get_texture(diffusesurf))
}

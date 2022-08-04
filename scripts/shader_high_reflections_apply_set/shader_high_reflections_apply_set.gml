/// shader_high_reflections_apply_set(ssrsurf, materialsurf, scenesurf)
/// @arg ssrsurf
/// @arg materialbuffer
/// @arg scenesurf

function shader_high_reflections_apply_set(ssrsurf, materialbuffer, scenesurf)
{
	texture_set_stage(sampler_map[?"uReflectionsBuffer"], surface_get_texture(ssrsurf))
	texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(materialbuffer))
	texture_set_stage(sampler_map[?"uSceneBuffer"], surface_get_texture(scenesurf))
	render_set_uniform_int("uGammaCorrect", app.project_render_gamma_correct)
}

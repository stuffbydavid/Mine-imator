/// shader_high_raytrace_reflections_set(raysurf, raysurf2, scenesurf, diffusesurf, materialsurf)
/// @arg raysurf
/// @arg raysurf2
/// @arg scenesurf
/// @arg diffusesurf
/// @arg materialsurf

function shader_high_raytrace_reflections_set(raysurf, raysurf2, scenesurf, diffusesurf, materialsurf)
{
	texture_set_stage(sampler_map[?"uRaytraceBuffer"], surface_get_texture(raysurf))
	texture_set_stage(sampler_map[?"uRaytrace2Buffer"], surface_get_texture(raysurf2))
	texture_set_stage(sampler_map[?"uSceneBuffer"], surface_get_texture(scenesurf))
	texture_set_stage(sampler_map[?"uDiffuseBuffer"], surface_get_texture(diffusesurf))
	texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(materialsurf))
	
	render_set_uniform("uNear", depth_near)
	render_set_uniform("uFar", depth_far)
	render_set_uniform("uProjMatrixInv", matrix_inverse(proj_matrix))
	
	render_set_uniform_color("uFallbackColor", render_background ? app.background_sky_color_final : c_black, 1)
	
	render_set_uniform("uFadeAmount", app.project_render_reflections_fade_amount)
	render_set_uniform_int("uGammaCorrect", app.project_render_gamma_correct)
}

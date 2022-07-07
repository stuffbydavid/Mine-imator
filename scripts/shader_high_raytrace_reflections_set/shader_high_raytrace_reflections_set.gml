/// shader_high_raytrace_reflections_set(raysurf, raysurf2, diffusesurf, normalsurf, normal2surf, depthsurf, materialsurf)
/// @arg raysurf
/// @arg raysurf2
/// @arg diffusesurf
/// @arg normalsurf
/// @arg normal2surf
/// @arg depthsurf
/// @arg materialsurf

function shader_high_raytrace_reflections_set(raysurf, raysurf2, diffusesurf, normalsurf, normal2surf, depthsurf, materialsurf)
{
	texture_set_stage(sampler_map[?"uRaytraceBuffer"], surface_get_texture(raysurf))
	texture_set_stage(sampler_map[?"uRaytrace2Buffer"], surface_get_texture(raysurf2))
	texture_set_stage(sampler_map[?"uDiffuseBuffer"], surface_get_texture(diffusesurf))
	//texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(normalsurf))
	//texture_set_stage(sampler_map[?"uNormalBufferExp"], surface_get_texture(normal2surf))
	//texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(depthsurf))
	texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(materialsurf))
	
	render_set_uniform("uNear", depth_near)
	render_set_uniform("uFar", depth_far)
	render_set_uniform("uProjMatrixInv", matrix_inverse(proj_matrix))
	
	if (render_pass = e_render_pass.REFLECTIONS)
		render_set_uniform_color("uFallbackColor", c_black, 1)
	else
		render_set_uniform_color("uFallbackColor", render_background ? app.background_sky_color_final : c_black, 1)
	
	render_set_uniform("uFadeAmount", app.project_render_reflections_fade_amount)
}

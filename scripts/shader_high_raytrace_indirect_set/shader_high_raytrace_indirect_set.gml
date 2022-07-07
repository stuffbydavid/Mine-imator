/// shader_high_raytrace_indirect_set(raysurf, raysurf2, lightingsurf, diffusesurf, normalsurf, normal2surf, depthsurf)
/// @arg raysurf
/// @arg raysurf2
/// @arg lightingsurf
/// @arg diffusesurf
/// @arg normalsurf
/// @arg normal2surf
/// @arg depthsurf

function shader_high_raytrace_indirect_set(raysurf, raysurf2, lightingsurf, diffusesurf, normalsurf, normal2surf, depthsurf)
{
	texture_set_stage(sampler_map[?"uRaytraceBuffer"], surface_get_texture(raysurf))
	texture_set_stage(sampler_map[?"uRaytrace2Buffer"], surface_get_texture(raysurf2))
	texture_set_stage(sampler_map[?"uLightingBuffer"], surface_get_texture(lightingsurf))
	texture_set_stage(sampler_map[?"uDiffuseBuffer"], surface_get_texture(diffusesurf))
	texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(normalsurf))
	texture_set_stage(sampler_map[?"uNormalBufferExp"], surface_get_texture(normal2surf))
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(depthsurf))
	
	render_set_uniform("uNear", depth_near)
	render_set_uniform("uFar", depth_far)
	render_set_uniform("uProjMatrixInv", matrix_inverse(proj_matrix))
}

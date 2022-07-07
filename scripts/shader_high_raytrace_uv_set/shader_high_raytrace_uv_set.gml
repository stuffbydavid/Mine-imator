/// shader_high_raytrace_uv_set(depthsurface, normalsurface, normalsurface2, [materialsurf])
/// @arg depthsurface
/// @arg normalsurface
/// @arg normalsurface2
/// @arg [materialsurf]

function shader_high_raytrace_uv_set(depthsurface, normalsurface, normalsurface2, materialsurf = undefined)
{
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(depthsurface))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], false)
	
	texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(normalsurface))
	texture_set_stage(sampler_map[?"uNormalBufferExp"], surface_get_texture(normalsurface2))
	
	// Material data not required for indirect raytrace
	if (materialsurf != undefined)
	{
		render_set_uniform_int("uSpecularRay", 1)
		texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(materialsurf))
		
		render_set_uniform("uPrecision", app.project_render_reflections_precision)
		render_set_uniform("uThickness", app.project_render_reflections_thickness)
	}
	else
	{
		render_set_uniform_int("uSpecularRay", 0)
		
		render_set_uniform("uPrecision", app.project_render_indirect_precision)
		render_set_uniform("uThickness", 1)
	}
	
	texture_set_stage(sampler_map[?"uNoiseBuffer"], surface_get_texture(render_sample_noise_texture))
	gpu_set_texrepeat_ext(sampler_map[?"uNoiseBuffer"], true)
	
	render_set_uniform("uNoiseSize", render_sample_noise_size)
	render_set_uniform("uNear", depth_near)
	render_set_uniform("uFar", depth_far)
	render_set_uniform("uProjMatrix", proj_matrix)
	render_set_uniform("uProjMatrixInv", matrix_inverse(proj_matrix))
	
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
}

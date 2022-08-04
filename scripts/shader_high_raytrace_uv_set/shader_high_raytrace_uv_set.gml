/// shader_high_raytrace_uv_set(mode, depthsurface, normalsurface, normalsurface2, materialsurf, [direction])
/// @arg mode
/// @arg depthsurface
/// @arg normalsurface
/// @arg normalsurface2
/// @arg materialsurf
/// @arg [direction]

function shader_high_raytrace_uv_set(mode, depthsurface, normalsurface, normalsurface2, materialsurf = undefined, dir)
{
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(depthsurface))
	texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(normalsurface))
	texture_set_stage(sampler_map[?"uNormalBufferExp"], surface_get_texture(normalsurface2))
	texture_set_stage(sampler_map[?"uNoiseBuffer"], surface_get_texture(render_sample_noise_texture))
	
	if (materialsurf != undefined)
		texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(materialsurf))
	
	gpu_set_texrepeat_ext(sampler_map[?"uNoiseBuffer"], true)
	
	render_set_uniform_int("uRayType", mode)
	
	if (mode = e_raytrace.INDIRECT)
	{
		render_set_uniform("uPrecision", app.project_render_indirect_precision)
		render_set_uniform("uThickness", 10)
		render_set_uniform("uRayDistance", 8000)
	}
	
	if (mode = e_raytrace.REFLECTIONS)
	{
		render_set_uniform("uPrecision", app.project_render_reflections_precision)
		render_set_uniform("uThickness", app.project_render_reflections_thickness)
		render_set_uniform("uRayDistance", 8000)
	}
	
	if (mode = e_raytrace.SHADOWS_DIRECTIONAL)
	{
		render_set_uniform("uPrecision", 1)
		render_set_uniform("uThickness", 1)
		render_set_uniform("uRayDistance", 2)
		
		dir = vec3_normalize(vec3_mul_matrix(vec3_mul(dir, -1), view_matrix));
		render_set_uniform_vec3("uRayDirection", dir[X], dir[Y], dir[Z])
	}
	
	render_set_uniform("uNoiseSize", render_sample_noise_size)
	render_set_uniform("uNear", depth_near)
	render_set_uniform("uFar", depth_far)
	render_set_uniform("uProjMatrix", proj_matrix)
	render_set_uniform("uProjMatrixInv", matrix_inverse(proj_matrix))
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
}

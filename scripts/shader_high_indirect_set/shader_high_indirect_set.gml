/// shader_high_indirect_set(depthsurface, normalsurface, normalsurface2, diffusesurf, shadowsurf, brightnesssurf)
/// @arg depthsurface
/// @arg normalsurface
/// @arg normalsurface2
/// @arg diffusesurf
/// @arg shadowsurf
/// @arg brightnesssurf

texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(argument0))
texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(argument1))
texture_set_stage(sampler_map[?"uNormalBufferExp"], surface_get_texture(argument2))
texture_set_stage(sampler_map[?"uDiffuseBuffer"], surface_get_texture(argument3))
texture_set_stage(sampler_map[?"uLightingBuffer"], surface_get_texture(argument4))
texture_set_stage(sampler_map[?"uBrightnessBuffer"], surface_get_texture(argument5))

render_set_uniform("uNear", cam_near)
render_set_uniform("uFar", cam_far)
render_set_uniform("uProjMatrix", proj_matrix)
render_set_uniform("uProjMatrixInv", matrix_inverse(proj_matrix))
render_set_uniform("uViewMatrix", view_proj_matrix)
render_set_uniform("uViewMatrixInv", matrix_inverse(view_proj_matrix))

render_set_uniform("uKernel", render_indirect_kernel)
render_set_uniform("uOffset", render_indirect_offset)

var stepsize, stepamount, raycount;

switch (app.setting_render_indirect_quality)
{
	// Low
	case 0:
	{
		raycount = 2
		stepamount = 8
		break;
	}
	
	// Medium
	case 1:
	{
		raycount = 4
		stepamount = 16
		break;
	}
	
	// High
	case 2:
	{
		raycount = 8
		stepamount = 32
		break;
	}
	
	// Best
	case 3:
	{
		raycount = 8
		stepamount = min(100, app.setting_render_indirect_range)
		break;
	}
}

stepsize = app.setting_render_indirect_range / stepamount

render_set_uniform("uStepSize", stepsize)
render_set_uniform_int("uStepAmount", stepamount)
render_set_uniform_int("uRays", raycount)

render_set_uniform("uDiffuseScatter", app.setting_render_indirect_scatter)

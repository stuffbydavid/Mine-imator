function shader_high_dof_coc_set(depthbuffer)
{
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(depthbuffer))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], false)
	
	render_set_uniform(e_uniform.DEPTH, render_camera_effects[e_value.CAM_FX_DOF_DEPTH])
	render_set_uniform(e_uniform.RANGE, render_camera_effects[e_value.CAM_FX_DOF_RANGE])
	render_set_uniform(e_uniform.FADE_SIZE, render_camera_effects[e_value.CAM_FX_DOF_FADE_SIZE])
	render_set_uniform(e_uniform.NEAR, depth_near)
	render_set_uniform(e_uniform.FAR, depth_far)
}

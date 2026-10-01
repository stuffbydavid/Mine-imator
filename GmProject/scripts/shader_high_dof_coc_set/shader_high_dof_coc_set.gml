function shader_high_dof_coc_set(depthbuffer)
{
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(depthbuffer))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], false)
	
	render_set_uniform("uDepth", render_camera_effects[e_value.CAM_FX_DOF_DEPTH])
	render_set_uniform("uRange", render_camera_effects[e_value.CAM_FX_DOF_RANGE])
	render_set_uniform("uFadeSize", render_camera_effects[e_value.CAM_FX_DOF_FADE_SIZE])
	render_set_uniform("uNear", depth_near)
	render_set_uniform("uFar", depth_far)
}

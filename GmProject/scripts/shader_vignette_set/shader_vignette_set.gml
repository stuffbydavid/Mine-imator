function shader_vignette_set()
{
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
	
	render_set_uniform("uRadius", render_camera_effects[e_value.CAM_FX_VIGNETTE_RADIUS])
	render_set_uniform("uSoftness", render_camera_effects[e_value.CAM_FX_VIGNETTE_SOFTNESS])
	render_set_uniform("uStrength", render_camera_effects[e_value.CAM_FX_VIGNETTE_STRENGTH])
	
	render_set_uniform_color("uColor", render_camera_effects[e_value.CAM_FX_VIGNETTE_COLOR], 1)
}

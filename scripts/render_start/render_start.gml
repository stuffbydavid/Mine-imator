/// render_start(target, camera, [width, height])
/// @arg target
/// @arg camera
/// @arg [width
/// @arg height]

render_target = argument[0]
render_camera = argument[1]
render_width = project_video_width
render_height = project_video_height

// Use camera settings
if (render_camera != null)
{
	if (!render_camera.value[e_value.CAM_SIZE_USE_PROJECT])
	{
		render_width = render_camera.value[e_value.CAM_WIDTH]
		render_height = render_camera.value[e_value.CAM_HEIGHT]
	}
	
	render_camera_bloom = (setting_render_camera_effects && render_camera.value[e_value.CAM_BLOOM])
	render_camera_dof = (setting_render_camera_effects && render_camera.value[e_value.CAM_DOF])
	render_camera_color_correction = (setting_render_camera_effects && render_camera.value[e_value.CAM_COLOR_CORRECTION])
	render_camera_grain = (setting_render_camera_effects && render_camera.value[e_value.CAM_GRAIN])
	render_camera_vignette = (setting_render_camera_effects && render_camera.value[e_value.CAM_VIGNETTE])
	
	render_camera_colors = (render_camera.value[e_value.ALPHA] < 1 || 
							render_camera.value[e_value.BRIGHTNESS] > 0 || 
							render_camera.value[e_value.MIX_COLOR] > 0 ||
							render_camera.value[e_value.RGB_ADD] != c_black ||
							render_camera.value[e_value.RGB_SUB] != c_black ||
							render_camera.value[e_value.RGB_MUL] != c_white ||
							render_camera.value[e_value.HSB_ADD] != c_black ||
							render_camera.value[e_value.HSB_SUB] != c_black ||
							render_camera.value[e_value.HSB_MUL] != c_red)
}
else 
{
	render_camera_bloom = false
	render_camera_dof = false
	render_camera_color_correction = false
	render_camera_grain = false
	render_camera_vignette = false
	render_camera_colors = false
}

// General rendering effects
render_glow = setting_render_glow
render_glow_falloff = setting_render_glow && setting_render_glow_falloff
render_aa = setting_render_aa

// Argument overwrites size
if (argument_count > 2)
{
	render_width = argument[2]
	render_height = argument[3]
}

render_ratio = render_width / render_height
render_overlay = (render_camera_colors || render_watermark)

// Effects must be in the order they're done in rendering
ds_list_clear(render_effects_list)
ds_list_add(render_effects_list,
	render_camera_bloom,
	render_camera_dof,
	render_glow,
	render_glow_falloff,
	render_aa,
	render_camera_color_correction,
	render_camera_grain,
	render_camera_vignette,
	render_overlay
)
render_effects_progress = 0
render_update_effects()

render_effects_progress = 0

render_prev_color = draw_get_color()
render_prev_alpha = draw_get_alpha()
draw_set_color(c_white)
draw_set_alpha(1)

render_update_text()

camera_apply(cam_render)
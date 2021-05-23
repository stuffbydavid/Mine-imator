/// render_start(target, camera, [width, height])
/// @arg target
/// @arg camera
/// @arg [width
/// @arg height]

function render_start()
{
	var finalrender = (setting_render_pass = e_render_pass.FINAL);
	
	render_target = argument[0]
	render_camera = argument[1]
	render_width = project_video_width
	render_height = project_video_height
	
	if (surface_exists(render_pass_surf))
		surface_free(render_pass_surf)
	
	render_pass_surf = null
	
	// General rendering effects
	render_ssao = setting_render_ssao && (setting_render_pass = e_render_pass.FINAL || setting_render_pass = e_render_pass.DEPTH_U24 || setting_render_pass = e_render_pass.NORMAL || setting_render_pass = e_render_pass.AO || setting_render_pass = e_render_pass.REFLECTIONS)
	render_shadows = setting_render_shadows && (setting_render_pass = e_render_pass.FINAL || setting_render_pass = e_render_pass.SHADOWS || setting_render_pass = e_render_pass.INDIRECT || setting_render_pass = e_render_pass.REFLECTIONS)
	render_indirect = setting_render_indirect && (setting_render_pass = e_render_pass.FINAL || setting_render_pass = e_render_pass.INDIRECT || setting_render_pass = e_render_pass.REFLECTIONS)
	render_reflections = setting_render_reflections && (setting_render_pass = e_render_pass.FINAL || setting_render_pass = e_render_pass.REFLECTIONS)
	
	render_volumetric_fog = setting_render_shadows && background_volumetric_fog && (render_quality = e_view_mode.RENDER)
	render_glow = setting_render_glow && (render_quality = e_view_mode.RENDER)
	render_glow_falloff = setting_render_glow && setting_render_glow_falloff && (render_quality = e_view_mode.RENDER)
	render_aa = setting_render_aa && (render_quality = e_view_mode.RENDER)
	
	// Use camera settings
	if (render_camera != null)
	{
		if (!render_camera.value[e_value.CAM_SIZE_USE_PROJECT])
		{
			render_width = render_camera.value[e_value.CAM_WIDTH]
			render_height = render_camera.value[e_value.CAM_HEIGHT]
		}
		
		render_camera_bloom = (render_effects && render_camera.value[e_value.CAM_BLOOM]) && finalrender
		render_camera_lens_dirt = (render_effects && render_camera.value[e_value.CAM_LENS_DIRT] && render_camera.value[e_value.TEXTURE_OBJ] != null) && finalrender
		render_camera_dof = (render_effects && render_camera.value[e_value.CAM_DOF]) && finalrender
		render_camera_color_correction = (render_effects && render_camera.value[e_value.CAM_COLOR_CORRECTION]) && finalrender
		render_camera_grain = (render_effects && render_camera.value[e_value.CAM_GRAIN]) && finalrender
		render_camera_vignette = (render_effects && render_camera.value[e_value.CAM_VIGNETTE]) && finalrender
		render_camera_ca = (render_effects && render_camera.value[e_value.CAM_CA]) && finalrender
		render_camera_distort = (render_effects && render_camera.value[e_value.CAM_DISTORT]) && finalrender
		
		render_camera_lens_dirt = render_camera_lens_dirt && ((render_camera_bloom && render_camera.value[e_value.CAM_LENS_DIRT_BLOOM]) || (render_glow && render_camera.value[e_value.CAM_LENS_DIRT_GLOW])) && finalrender
		render_camera_lens_dirt_bloom = render_camera_lens_dirt && render_camera.value[e_value.CAM_LENS_DIRT_BLOOM] && finalrender
		render_camera_lens_dirt_glow = render_camera_lens_dirt && render_camera.value[e_value.CAM_LENS_DIRT_GLOW] && finalrender
		
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
		render_camera_ca = false
		render_camera_distort = false
		
		render_camera_lens_dirt = false
		render_camera_lens_dirt_bloom = false
		render_camera_lens_dirt_glow = false
		
		render_camera_colors = false
	}
	
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
		render_volumetric_fog,
		render_camera_dof,
		render_camera_bloom,
		render_glow,
		render_glow_falloff,
		render_aa,
		render_camera_ca,
		render_camera_distort,
		render_camera_lens_dirt,
		render_camera_color_correction,
		render_camera_grain,
		render_camera_vignette,
		render_overlay
	)
	
	render_effects_progress = -1
	render_post_index = 0
	render_effects_done = false
	
	render_prev_color = draw_get_color()
	render_prev_alpha = draw_get_alpha()
	draw_set_color(c_white)
	draw_set_alpha(1)
	
	render_update_text()
	render_update_item()
	
	camera_apply(cam_render)
}

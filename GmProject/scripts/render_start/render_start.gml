/// render_start(target, camera, [width, height])
/// @arg target
/// @arg camera
/// @arg [width
/// @arg height]

function render_start()
{
	render_target = argument[0]
	render_camera = argument[1]
	render_width = project_video_width
	render_height = project_video_height
	
	if (surface_exists(render_pass_surf))
		surface_free(render_pass_surf)
	
	render_pass_surf = null
	render_world_count = 0
	
	render_pass = project_render_pass
	
	// General rendering effects
	render_ssao = project_render_ssao && (render_pass = e_render_pass.COMBINED || render_pass = e_render_pass.DEPTH_U24 || render_pass = e_render_pass.NORMAL || render_pass = e_render_pass.AO || render_pass = e_render_pass.REFLECTIONS)
	render_shadows = project_render_shadows && (render_pass = e_render_pass.COMBINED || render_pass = e_render_pass.SHADOWS || render_pass = e_render_pass.SPECULAR || render_pass = e_render_pass.INDIRECT || render_pass = e_render_pass.INDIRECT_SHADOWS || render_pass = e_render_pass.REFLECTIONS)
	render_indirect = render_shadows && project_render_indirect && (render_pass = e_render_pass.COMBINED || render_pass = e_render_pass.INDIRECT || render_pass = e_render_pass.INDIRECT_SHADOWS || render_pass = e_render_pass.REFLECTIONS)
	render_reflections = project_render_reflections && (render_pass = e_render_pass.COMBINED || render_pass = e_render_pass.REFLECTIONS)
	
	render_glow = project_render_glow && (render_quality = e_view_mode.RENDER)
	render_glow_falloff = project_render_glow && project_render_glow_falloff && (render_quality = e_view_mode.RENDER)
	
	render_depth_normals = (render_ssao || render_indirect || render_reflections || project_render_subsurface_samples >= 0)
	
	// Use camera settings
	if (render_camera != null)
	{
		if (!render_camera.value[e_value.CAM_SIZE_USE_PROJECT])
		{
			render_width = render_camera.value[e_value.CAM_WIDTH]
			render_height = render_camera.value[e_value.CAM_HEIGHT]
		}
		
		if (render_camera.value[e_value.CAM_LIGHT_MANAGEMENT])
		{
			render_tonemapper = render_camera.value[e_value.CAM_TONEMAPPER]
			render_exposure = render_camera.value[e_value.CAM_EXPOSURE]
			render_gamma = render_camera.value[e_value.CAM_GAMMA]
		}
		else
		{
			render_tonemapper = project_render_tonemapper
			render_exposure = project_render_exposure
			render_gamma = project_render_gamma
		}
		
		render_camera_bloom = (render_effects && render_camera.value[e_value.CAM_BLOOM]) && !render_pass
		render_camera_lens_dirt = (render_effects && render_camera.value[e_value.CAM_LENS_DIRT] && render_camera.value[e_value.TEXTURE_OBJ] != null) && !render_pass
		render_camera_dof = (render_effects && render_camera.value[e_value.CAM_DOF]) && !render_pass
		render_camera_color_correction = (render_effects && render_camera.value[e_value.CAM_COLOR_CORRECTION]) && !render_pass
		render_camera_grain = (render_effects && render_camera.value[e_value.CAM_GRAIN]) && !render_pass
		render_camera_vignette = (render_effects && render_camera.value[e_value.CAM_VIGNETTE]) && !render_pass
		render_camera_ca = (render_effects && render_camera.value[e_value.CAM_CA]) && !render_pass
		render_camera_distort = (render_effects && render_camera.value[e_value.CAM_DISTORT]) && !render_pass
		
		render_camera_lens_dirt = render_camera_lens_dirt && ((render_camera_bloom && render_camera.value[e_value.CAM_LENS_DIRT_BLOOM]) || (render_glow && render_camera.value[e_value.CAM_LENS_DIRT_GLOW])) && !render_pass
		render_camera_lens_dirt_bloom = render_camera_lens_dirt && render_camera.value[e_value.CAM_LENS_DIRT_BLOOM] && !render_pass
		render_camera_lens_dirt_glow = render_camera_lens_dirt && render_camera.value[e_value.CAM_LENS_DIRT_GLOW] && !render_pass
		
		render_camera_colors = (render_camera.value[e_value.ALPHA] < 1 || 
								render_camera.value[e_value.EMISSIVE] > 0 || 
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
		
		render_tonemapper = project_render_tonemapper
		render_exposure = project_render_exposure
		render_gamma = project_render_gamma
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
	render_refresh_effects()
	
	// Update timeline visiblity
	with (obj_timeline)
		render_visible = tl_get_visible()
	
	render_prev_color = draw_get_color()
	render_prev_alpha = draw_get_alpha()
	draw_set_color(c_white)
	draw_set_alpha(1)
	
	render_update_text()
	render_update_item()
	render_update_camera()
	
	camera_apply(cam_render)
}

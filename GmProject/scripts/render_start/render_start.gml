/// @arg target
/// @arg camera
/// @arg owner
/// @arg [width]
/// @arg [height]

function render_start(target, camera, owner, wid = null, hei = null)
{
	render_start_time = get_timer()
	render_start_surface_time = benchmark_surface_total_time

	render_target = target
	render_camera = camera
	render_camera_effects = null
	render_camera_effect_enabled = null
	
	render_pack_current = res_eval(project_pack_res)
	
	if ((owner = app.view_second && render_effects) || owner = "image" || owner = "movie" || owner = camera)
	{
		var fxscope = camera != null ? camera : app;
		with (fxscope)
			render_camera_effects = tl_camera_effects_get()
		
		render_camera_effect_enabled = fxscope.camera_effect_enabled
	}
	
	render_width = project_video_width
	render_height = project_video_height
	
	if (surface_exists(render_pass_surf))
		surface_free(render_pass_surf)
	
	for (var pass = 0; pass < array_length(render_pass_surfs); pass++)
		if (surface_exists(render_pass_surfs[pass]))
			surface_free(render_pass_surfs[pass])
	
	render_pass_surf = null
	render_pass_surfs = array_create(e_render_pass.amount, null)
	render_world_count = 0
	
	render_pass = project_render_pass
	render_use_samples = (renderer_current = e_renderer.REALISTIC)
	
	// Apply render preset
	render_apply_settings(render_preset_map[?project_render_preset[renderer_current]], renderer_current)
	
	// Update timeline visibility and glow/glint usage
	var checkglow, checkglint;
	checkglow = (project_render_glow && renderer_current != e_renderer.QUICK)
	checkglint = (project_render_glint_strength != 0)
	render_glow = false
	render_glint = false
	render_fog_combined = false
	render_sun_combined = false
	render_color_combined = false
	
	with (obj_timeline)
	{
		var vis = tl_get_visible();
		if (render_visible != vis)
			render_scene_bounds = null
		
		render_visible = vis
		
		if (render_visible)
		{
			if (checkglow && !render_glow && glow)
				render_glow = true
		
			if (checkglint && !render_glint && glint_enabled && glint_strength != 0)
				render_glint = true
		}
	}
	
	if (renderer_current = e_renderer.STANDARD)
	{
		project_render_indirect = false
		project_render_reflections = false
		project_render_aa_mode = e_aa_mode.FXAA
	}
	
	render_cascades_count = project_render_shadows_sun_cascades
	
	// General rendering effects
	var renderall, rendercombined, reflectionpass, indirectpass, shadowpass, ssaopass, fogpass, glowpass, subsurfacepass;
	renderall = (render_pass = e_render_pass.ALL)
	rendercombined = (renderall || render_pass = e_render_pass.COMBINED || render_pass = e_render_pass.BLOOM_THRESHOLD || render_pass = e_render_pass.BLOOM_BLUR)
	reflectionpass = (render_pass = e_render_pass.REFLECTIONS)
	indirectpass = (reflectionpass || render_pass = e_render_pass.INDIRECT || render_pass = e_render_pass.INDIRECT_SHADOWS)
	shadowpass = (indirectpass || render_pass = e_render_pass.SHADOWS || render_pass = e_render_pass.SPECULAR)
	ssaopass = (reflectionpass || render_pass = e_render_pass.DEPTH || render_pass = e_render_pass.NORMAL || render_pass = e_render_pass.AO)
	fogpass = (render_pass = e_render_pass.FOG)
	glowpass = (render_pass = e_render_pass.GLOW)
	subsurfacepass = (render_pass = e_render_pass.SUBSURFACE || render_pass = e_render_pass.SUBSURFACE_RANGE)
	
	render_ssao = (project_render_ssao && (rendercombined || ssaopass))
	render_shadows = (project_render_shadows && (rendercombined || shadowpass))
	render_indirect = (render_shadows && project_render_indirect && (rendercombined || indirectpass))
	render_reflections = (project_render_reflections && (rendercombined || reflectionpass))
	
	// Set auxiliary requirements
	render_auxiliary_material = (renderer_current = e_renderer.REALISTIC && (project_render_subsurface_samples > 0 || renderall || subsurfacepass))
	render_auxiliary = (env_fog_show || renderall || fogpass || glowpass || subsurfacepass || render_auxiliary_material || render_glow)
	
	// Use camera size
	if (render_camera != null && !render_camera.value[e_value.CAM_SIZE_USE_PROJECT])
	{
		render_width = render_camera.value[e_value.CAM_WIDTH]
		render_height = render_camera.value[e_value.CAM_HEIGHT]
	}
	
	// Camera effects
	render_camera_bloom = false
	render_camera_dof = false
	render_camera_cc = false
	render_camera_grain = false
	render_camera_vignette = false
	render_camera_ca = false
	render_camera_distort = false
		
	render_camera_lens_dirt = false
	render_camera_lens_dirt_bloom = false
	render_camera_lens_dirt_glow = false
	
	render_tonemapper = project_render_tonemapper
	render_exposure = project_render_exposure
	render_gamma = project_render_gamma
		
	render_camera_colors = false
		
	if (render_camera_effects != null)
	{
		if (render_camera_effect_enabled[e_cam_fx.LIGHT_MANAGEMENT])
		{
			render_tonemapper = render_camera_effects[e_value.CAM_FX_TONEMAPPER]
			render_exposure = render_camera_effects[e_value.CAM_FX_EXPOSURE]
			render_gamma = render_camera_effects[e_value.CAM_FX_GAMMA]
		}
		
		if (render_effects && rendercombined)
		{
			render_camera_bloom = render_camera_effect_enabled[e_cam_fx.BLOOM]
			render_camera_dof = render_camera_effect_enabled[e_cam_fx.DOF]
			render_camera_cc = render_camera_effect_enabled[e_cam_fx.COLOR_CORRECTION]
			render_camera_grain = render_camera_effect_enabled[e_cam_fx.GRAIN]
			render_camera_vignette = render_camera_effect_enabled[e_cam_fx.VIGNETTE]
			render_camera_ca = render_camera_effect_enabled[e_cam_fx.CA]
			render_camera_distort = render_camera_effect_enabled[e_cam_fx.DISTORT]
		
			render_camera_lens_dirt = render_camera_effect_enabled[e_cam_fx.LENS_DIRT] &&
				instance_exists(render_camera_effects[e_value.TEXTURE_OBJ]) &&
				((render_camera_bloom && render_camera_effects[e_value.CAM_FX_LENS_DIRT_BLOOM]) ||
				(render_glow && render_camera_effects[e_value.CAM_FX_LENS_DIRT_GLOW]))
			render_camera_lens_dirt_bloom = render_camera_lens_dirt && render_camera_effects[e_value.CAM_FX_LENS_DIRT_BLOOM]
			render_camera_lens_dirt_glow = render_camera_lens_dirt && render_camera_effects[e_value.CAM_FX_LENS_DIRT_GLOW]
		
			render_camera_colors = (render_camera_effect_enabled[e_cam_fx.FADE] || render_camera_effect_enabled[e_cam_fx.COLOR_CORRECTION])
		}
	}
	
	render_gamma = max(render_gamma, 0.01)
	
	depth_near = clip_near
	depth_far = app.project_render_distance

	// Argument overwrites size
	if (wid != null && hei != null)
	{
		render_width = wid
		render_height = hei
	}

	// Re-use surfaces created for this render owner and output size
	render_surface_pool_set(owner, render_width, render_height)

	render_ratio = render_width / render_height
	render_overlay = (render_camera_colors || render_watermark)
	
	// Effects must be in the order they're done in rendering
	render_refresh_effects()
	
	// Optimizations
	render_alpha_hash_allowed = false
	render_alpha_hash_shadows = false
	render_shadow_cache_enabled = false
	render_gbuffers_cache_enabled = false
	
	if (renderer_current = e_renderer.REALISTIC)
	{
		var set, opt;
		set = render_preset_map[?project_render_preset[e_renderer.REALISTIC]].renderer[e_renderer.REALISTIC];
		opt = render_optimizations_state(set)
		opt[1] = (opt[1] && project_render_alpha_mode != e_alpha_mode.HASHED && render_alpha_hashed_count = 0)
		
		render_alpha_hash_allowed = true
		render_alpha_hash_shadows = project_render_shadows_transparent
		render_shadow_cache_enabled = opt[0]
		render_gbuffers_cache_enabled = opt[1]
	}
	
	render_prev_color = draw_get_color()
	render_prev_alpha = draw_get_alpha()
	
	draw_set_color(c_white)
	draw_set_alpha(1)
	
	render_update_text()
	render_update_item()
	render_update_camera()
	
	camera_apply(cam_render)
}

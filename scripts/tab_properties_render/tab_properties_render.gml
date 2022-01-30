/// tab_properties_render()

function tab_properties_render()
{
	// Render samples
	tab_control_meter()
	draw_meter("rendersamples", dx, dy, dw, project_render_samples, 50, 1, 256, 16, 1, tab.render.tbx_samples, action_project_render_samples) 
	tab_next()
	
	// Samples tooltip
	var text, icon, type;
	
	if (project_render_samples >= 1 && project_render_samples <= 8)
	{
		text = "rendersamples0"
		icon = icons.TICK
		type = e_toast.POSITIVE
	}
	
	if (project_render_samples >= 9 && project_render_samples <= 32)
	{
		text = "rendersamples1"
		icon = icons.TICK
		type = e_toast.POSITIVE
	}
	
	if (project_render_samples >= 33 && project_render_samples <= 64)
	{
		text = "rendersamples2"
		icon = icons.TICK
		type = e_toast.POSITIVE
	}
	
	if (project_render_samples >= 65 && project_render_samples <= 128)
	{
		text = "rendersamples3"
		icon = icons.WARNING_TRIANGLE
		type = e_toast.WARNING
	}
	
	if (project_render_samples >= 129)
	{
		text = "rendersamples4"
		icon = icons.WARNING_TRIANGLE
		type = e_toast.NEGATIVE
	}
	
	draw_tooltip_label(text, icon, type)
	
	// SSAO
	tab_control_switch()
	draw_button_collapse("ssao", collapse_map[?"ssao"], action_project_render_ssao, project_render_ssao, "renderssao")
	tab_next()
	
	if (project_render_ssao && collapse_map[?"ssao"])
	{
		tab_collapse_start()
		
		tab_control_dragger()
		draw_dragger("renderssaoradius", dx, dy, dragger_width, project_render_ssao_radius, project_render_ssao_radius / 200, 0, 256, 12, 0, tab.render.tbx_ssao_radius, action_project_render_ssao_radius)
		tab_next()
		
		tab_control_dragger()
		draw_dragger("renderssaopower", dx, dy, dragger_width, round(project_render_ssao_power * 100), .5, 0, no_limit * 100, 100, 1, tab.render.tbx_ssao_power, action_project_render_ssao_power)
		tab_next()
		
		tab_control_meter()
		draw_meter("renderssaoblurpasses", dx, dy, dw, project_render_ssao_blur_passes, 50, 0, 8, 2, 1, tab.render.tbx_ssao_blur_passes, action_project_render_ssao_blur_passes)
		tab_next()
		
		tab_control_color()
		draw_button_color("renderssaocolor", dx, dy, dw, project_render_ssao_color, c_black, false, action_project_render_ssao_color)
		tab_next()
		
		tab_collapse_end()
	}
	
	// Shadows
	tab_control_switch()
	draw_button_collapse("shadows", collapse_map[?"shadows"], action_project_render_shadows, project_render_shadows, "rendershadows")
	tab_next()
	
	if (project_render_shadows && collapse_map[?"shadows"])
	{
		tab_collapse_start()
		
		tab_control_menu()
		draw_button_menu("rendershadowssunbuffersize", e_menu.LIST, dx, dy, dw, 24, project_render_shadows_sun_buffer_size, text_get("rendershadowsbuffersize" + string(project_render_shadows_sun_buffer_size)) + " (" + string(project_render_shadows_sun_buffer_size) + "x" + string(project_render_shadows_sun_buffer_size) + ")", action_project_render_shadows_sun_buffer_size)
		tab_next()
		
		tab_control_menu()
		draw_button_menu("rendershadowsspotbuffersize", e_menu.LIST, dx, dy, dw, 24, project_render_shadows_spot_buffer_size, text_get("rendershadowsbuffersize" + string(project_render_shadows_spot_buffer_size)) + " (" + string(project_render_shadows_spot_buffer_size) + "x" + string(project_render_shadows_spot_buffer_size) + ")", action_project_render_shadows_spot_buffer_size)
		tab_next()
		
		tab_control_menu()
		draw_button_menu("rendershadowspointbuffersize", e_menu.LIST, dx, dy, dw, 24, project_render_shadows_point_buffer_size, text_get("rendershadowsbuffersize" + string(project_render_shadows_point_buffer_size)) + " (" + string(project_render_shadows_point_buffer_size) + "x" + string(project_render_shadows_point_buffer_size) + ")", action_project_render_shadows_point_buffer_size)
		tab_next()
		
		tab_collapse_end()
	}
	
	// Subsurface scattering
	tab_control_switch()
	draw_button_collapse("subsurface", collapse_map[?"subsurface"], null, true, "rendersubsurfacescattering")
	tab_next()
	
	if (collapse_map[?"subsurface"])
	{
		tab_collapse_start()
		
		tab_control_meter()
		draw_meter("rendersubsurfacescatterquality", dx, dy, dw, project_render_subsurface_samples, 64, 1, 32, 7, 1, tab.render.tbx_subsurface_samples, action_project_render_subsurface_samples)
		tab_next()
		
		tab_control_meter()
		draw_meter("rendersubsurfacescatterjitter", dx, dy, dw, round(project_render_subsurface_jitter * 100), 64, 1, 100, 30, 1, tab.render.tbx_subsurface_jitter, action_project_render_subsurface_jitter)
		tab_next()
		
		tab_collapse_end()
	}
	
	// Indirect lighting
	tab_control_switch()
	draw_button_collapse("indirect", collapse_map[?"indirect"], action_project_render_indirect, project_render_indirect, "renderindirect")
	tab_next()
	
	if (project_render_indirect && collapse_map[?"indirect"])
	{
		tab_collapse_start()
		
		tab_control_meter()
		draw_meter("renderreflectionsprecision", dx, dy, dw, round(project_render_indirect_precision * 100), 50, 0, 100, 30, 1, tab.render.tbx_indirect_precision, action_project_render_indirect_precision)
		tab_next()
		
		tab_control_meter()
		draw_meter("renderindirectblurpasses", dx, dy, dw, project_render_indirect_blur_passes, 50, 0, 8, 2, 1, tab.render.tbx_indirect_blur_passes, action_project_render_indirect_blur_passes)
		tab_next()
		
		tab_control_dragger()
		draw_dragger("renderindirectstrength", dx, dy, dragger_width, round(project_render_indirect_strength * 100), .5, 0, no_limit * 100, 100, 1, tab.render.tbx_indirect_strength, action_project_render_indirect_strength) 
		tab_next()
		
		tab_collapse_end()
	}
	
	// Reflections
	tab_control_switch()
	draw_button_collapse("reflections", collapse_map[?"reflections"], action_project_render_reflections, project_render_reflections, "renderreflections")
	tab_next()
	
	if (project_render_reflections && collapse_map[?"reflections"])
	{
		tab_collapse_start()
		
		tab_control_meter()
		draw_meter("renderreflectionsprecision", dx, dy, dw, round(project_render_reflections_precision * 100), 50, 0, 100, 30, 1, tab.render.tbx_reflections_precision, action_project_render_reflections_precision)
		tab_next()
		
		tab_control_meter()
		draw_meter("renderreflectionsfadeamount", dx, dy, dw, round(project_render_reflections_fade_amount * 100), 50, 0, 100, 50, 1, tab.render.tbx_reflections_fade_amount, action_project_render_reflections_fade_amount)
		tab_next()
		
		tab_control_dragger()
		draw_dragger("renderreflectionsthickness", dx, dy, dragger_width, project_render_reflections_thickness, 1, .1, no_limit, 1, .1, tab.render.tbx_reflections_thickness, action_project_render_reflections_thickness) 
		tab_next()
		
		tab_collapse_end()
	}
	
	// Glow
	tab_control_switch()
	draw_button_collapse("glow", collapse_map[?"glow"], action_project_render_glow, project_render_glow, "renderglow")
	tab_next()
	
	if (project_render_glow && collapse_map[?"glow"])
	{
		tab_collapse_start()
		
		tab_control_dragger()
		draw_dragger("renderglowradius", dx, dy, dragger_width, round(project_render_glow_radius * 100), .5, 0, no_limit * 100, 100, 1, tab.render.tbx_glow_radius, action_project_render_glow_radius)
		tab_next()
		
		tab_control_dragger()
		draw_dragger("renderglowintensity", dx, dy, dragger_width, round(project_render_glow_intensity * 100), .5, 0, no_limit * 100, 100, 1, tab.render.tbx_glow_intensity, action_project_render_glow_intensity)
		tab_next()
		
		tab_control_switch()
		draw_button_collapse("glow_falloff", collapse_map[?"glow_falloff"], action_project_render_glow_falloff, project_render_glow_falloff, "renderglowfalloff")
		tab_next()
		
		// Secondary glow
		if (project_render_glow_falloff && collapse_map[?"glow_falloff"])
		{
			tab_collapse_start()
			
			tab_control_dragger()
			draw_dragger("renderglowfalloffradius", dx, dy, dragger_width, round(project_render_glow_falloff_radius * 100), .5, 0, no_limit * 100, 200, 1, tab.render.tbx_glow_falloff_radius, action_project_render_glow_falloff_radius)
			tab_next()
			
			tab_control_dragger()
			draw_dragger("renderglowfalloffintensity", dx, dy, dragger_width, round(project_render_glow_falloff_intensity * 100), .5, 0, no_limit * 100, 100, 1, tab.render.tbx_glow_falloff_intensity, action_project_render_glow_falloff_intensity)
			tab_next()
			
			tab_collapse_end(false)
		}
		
		tab_collapse_end()
	}
	
	// AA
	tab_control_switch()
	draw_button_collapse("aa", collapse_map[?"aa"], action_project_render_aa, project_render_aa, "renderaa")
	tab_next()
	
	if (project_render_aa && collapse_map[?"aa"])
	{
		tab_collapse_start()
		
		tab_control_meter()
		draw_meter("renderaapower", dx, dy, dw, round(project_render_aa_power * 100), 48, 0, 300, 100, 1, tab.render.tbx_aa_power, action_project_render_aa_power)
		tab_next()
		
		tab_collapse_end()
	}
	
	// Texture filtering
	tab_control_switch()
	draw_button_collapse("texfilter", collapse_map[?"texfilter"], action_project_render_texture_filtering, project_render_texture_filtering, "rendertexturefiltering")
	tab_next()
	
	if (project_render_texture_filtering && collapse_map[?"texfilter"])
	{
		tab_collapse_start()
		
		// Transparent block texture filtering
		tab_control_switch()
		draw_switch("rendertexturefilteringtransparentblocks", dx, dy, project_render_transparent_block_texture_filtering, action_project_render_transparent_block_texture_filtering)
		tab_next()
		
		// Texture filtering level
		tab_control_meter()
		draw_meter("rendertexturefilteringlevel", dx, dy, dw, project_render_texture_filtering_level, 48, 0, 5, 1, 1, tab.render.tbx_texture_filtering_level, action_project_render_texture_filtering_level)
		tab_next()
		
		tab_collapse_end()
	}
	
	// Camera effects
	tab_control_switch()
	draw_button_collapse("camera_effects", collapse_map[?"camera_effects"], null, true, "rendercameraeffects")
	tab_next()
	
	if (collapse_map[?"camera_effects"])
	{
		tab_collapse_start()
		
		// DOF quality
		tab_control_meter()
		draw_meter("renderdofquality", dx, dy, dw, project_render_dof_quality, 50, 1, 5, 3, 1, tab.render.tbx_dof_quality, action_project_render_dof_quality)
		tab_next()
		
		tab_collapse_end()
	}
	
	// Models and scenery
	tab_control_switch()
	draw_button_collapse("models_scenery", collapse_map[?"models_scenery"], null, true, "rendermodelsscenery")
	tab_next()
	
	if (collapse_map[?"models_scenery"])
	{
		tab_collapse_start()
		
		// Bending style
		tab_control_togglebutton()
		togglebutton_add("renderbendstylerealistic", null, "realistic", project_bend_style = "realistic", action_project_bend_style)
		togglebutton_add("renderbendstyleblocky", null, "blocky", project_bend_style = "blocky", action_project_bend_style)
		draw_togglebutton("renderbendstyle", dx, dy)
		tab_next()
		
		// Random blocks
		tab_control_switch()
		draw_switch("renderrandomblocks", dx, dy, project_render_random_blocks, action_project_render_random_blocks)
		tab_next()
		
		// Liquid waves
		tab_control_switch()
		draw_switch("renderliquidanimation", dx, dy, project_render_liquid_animation, action_project_render_liquid_animation)
		tab_next()
		
		// Noisy grass/water
		tab_control_switch()
		draw_switch("rendernoisygrasswater", dx, dy, project_render_noisy_grass_water, action_project_render_noisy_grass_water)
		tab_next()
		
		// Block emission
		tab_control_meter()
		draw_meter("renderblockemission", dx, dy, dw, round(project_render_block_brightness * 100), 48, 0, 100, 75, 1, tab.render.tbx_block_brightness, action_project_render_block_brightness)
		tab_next()
		
		// Apply glow to bright blocks
		tab_control_switch()
		draw_switch("renderblockglow", dx, dy, project_render_block_glow, action_project_render_block_glow)
		tab_next()
		
		// Glow threshold
		if (project_render_block_glow)
		{
			tab_control_meter()
			draw_meter("renderblockglowthreshold", dx, dy, dw, round(project_render_block_glow_threshold * 100), 48, 0, 100, 75, 1, tab.render.tbx_block_glow_threshold, action_project_render_block_glow_threshold)
			tab_next()
		}
		
		// Block subsurface (Used for simple SSS in scenery)
		tab_control_dragger()
		draw_dragger("renderblocksubsurfaceradius", dx, dy, dragger_width, project_render_block_subsurface, .1, 0, no_limit, 2, 0.01, tab.render.tbx_block_subsurface_radius, action_project_render_block_subsurface)
		tab_next()
		
		tab_collapse_end()
	}
	
	tab_control(24)
	
	// Import render settings
	if (draw_button_icon("renderimport", dx, dy, 24, 24, false, icons.SETTINGS_IMPORT, null, false, "tooltipsettingsimport"))
		action_project_render_import()
	
	// Export render settings
	if (draw_button_icon("renderexport", dx + 28, dy, 24, 24, false, icons.SETTINGS_EXPORT, null, false, "tooltipsettingsexport"))
		action_project_render_export()
	
	// Set current render settings as default
	if (draw_button_icon("rendersetdefault", dx + (28 * 2), dy, 24, 24, false, icons.SETTINGS_SET_DEFAULT, null, false, "tooltipsettingssetdefault"))
	{
		if (question(text_get("questionsetasdefault")))
			action_project_render_export(render_default_file)
	}
	
	// Reset render settings
	draw_button_icon("renderreset", dx + (28 * 3), dy, 24, 24, false, icons.RESET, action_project_render_reset, false, "tooltipsettingsreset")
	
	tab_next()
}

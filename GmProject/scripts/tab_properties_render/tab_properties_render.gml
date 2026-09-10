/// tab_properties_render()

function tab_properties_render()
{
	var text, dividew;
	dividew = content_width - floor(tab.scroll.needed * 12)
	
	#region SPECIALEFFECTS
	
	tab_control(16)
	draw_label(text_get("renderspecialeffects"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_label) 
	tab_next()
	
	renderer_edit = tab.render.renderer
	
	// Renderer
	tab_control_menu()
	draw_button_menu("renderrenderer", e_menu.LIST, dx, dy, dw, 24, renderer_edit, text_get("renderrenderer" + renderer_name_list[renderer_edit]), action_project_renderer)
	tab_next()
	
	dy += 8
	
	// Presets
	var presetlist, buttoncount, buttonsperrow, buttonrows;
	presetlist = render_preset_list[renderer_edit]
	buttoncount = ds_list_size(presetlist)
	if (buttoncount > 3)
		buttonsperrow = 2
	else
		buttonsperrow = buttoncount
	buttonrows = ceil(buttoncount / buttonsperrow)
	
	tab_control_togglebutton(buttonrows)
	for (var i = 0; i < buttoncount; i++)
	{
		var file, name;
		file = presetlist[|i]
		name = render_preset_map[?file].name
		if (text_exists("renderpreset" + name))
			text = text_get("renderpreset" + name)
		else
			text = name
		togglebutton_add("renderpreset" + file, null, file, project_render_preset[renderer_edit] = file, action_project_render_preset, false, text)
	}
	draw_togglebutton("renderpreset", dx, dy)
	tab_next()
	
	var presetid, rendererset;
	presetid = project_render_preset[renderer_edit]
	render_preset_edit = render_preset_map[?presetid]
	rendererset = render_preset_edit.renderer[renderer_edit]
	
	var setx = dx;
	tab_control(24)
		
	// Reset render settings
	draw_button_icon("renderreset", setx, dy, 24, 24, false, icons.RESET, action_project_render_preset_reset, render_preset_edit.locked, "tooltipsettingsreset")
		
	setx += 28
	draw_divide_vertical(setx, dy, 24)
	setx += 4
	
	// Import render settings
	if (draw_button_icon("renderimport", setx, dy, 24, 24, false, icons.SETTINGS_IMPORT, null, render_preset_edit.locked, "tooltipsettingsimport"))
		action_project_render_preset_import()
	setx += 28
	
	// Export render settings
	if (draw_button_icon("renderexport", setx, dy, 24, 24, false, icons.SETTINGS_EXPORT, null, false, "tooltipsettingsexport"))
		action_project_render_preset_export()
	setx += 28
			
	// Set current render settings as default
	if (draw_button_icon("rendersetdefault", setx, dy, 24, 24, false, icons.SETTINGS_SETDEFAULT, null, false, "tooltipsettingssetdefault"))
		action_project_render_preset_export(render_default_file)
	setx += 28
	
	if (presetid != "custom")
	{
		if (draw_button_icon("renderunlock", setx, dy, 24, 24, false, render_preset_edit.locked ? icons.LOCK : icons.UNLOCK, null, false, render_preset_edit.locked ? "tooltipsettingsunlock" : "tooltipsettingslock"))
			render_preset_edit.locked = !render_preset_edit.locked
	}
	tab_next()
	dy += 2
	
	// Performance warning
	if (render_performance_warning(render_preset_edit, renderer_edit))
		draw_tooltip_label("renderrenderer" + renderer_name_list[renderer_edit] + "warning", icons.WARNING_TRIANGLE, e_toast.WARNING)
	
	if (renderer_edit = e_renderer.REALISTIC)
	{
		// Render samples
		tab_control_dragger()
		draw_dragger("rendersamples", dx, dy, dragger_width, rendererset.samples, .5, 1, 256, 24, 1, tab.render.tbx_samples, action_project_render_samples)
		tab_next()
	}
	
	// SSAO
	tab_control_switch()
	draw_button_collapse("ssao", collapse_map[?"ssao"], action_project_render_ssao, rendererset.ssao, "renderssao", "renderssaotip")
	tab_next()
	
	if (rendererset.ssao && collapse_map[?"ssao"])
	{
		tab_collapse_start()
		
		tab_control_dragger()
		draw_dragger("renderssaoradius", dx, dy, dragger_width, project_render_ssao_radius, project_render_ssao_radius / 200, 0, 256, 12, 0.1, tab.render.tbx_ssao_radius, action_project_render_ssao_radius)
		tab_next()
		
		tab_control_dragger()
		draw_dragger("renderssaopower", dx, dy, dragger_width, round(project_render_ssao_power * 100), .5, 0, no_limit * 100, 100, 1, tab.render.tbx_ssao_power, action_project_render_ssao_power)
		tab_next()
		
		tab_control_color()
		draw_button_color("renderssaocolor", dx, dy, dw, project_render_ssao_color, c_black, false, action_project_render_ssao_color)
		tab_next()
		
		tab_control_switch()
		draw_switch("renderssaoalwaysvisible", dx, dy, project_render_ssao_always_visible, action_project_render_ssao_always_visible, "renderssaoalwaysvisibletip")
		tab_next()
		
		tab_collapse_end()
	}
	
	// Shadows
	tab_control_switch()
	draw_button_collapse("shadows", collapse_map[?"shadows"], action_project_render_shadows, rendererset.shadows, "rendershadows")
	tab_next()
	
	if (rendererset.shadows && collapse_map[?"shadows"])
	{
		tab_collapse_start()
		
		tab_control_meter()
		draw_meter("rendershadowssuncascades", dx, dy, dw, rendererset.shadows_sun_cascades, 1, 5, 2, 1, tab.render.tbx_shadows_sun_cascades, action_project_render_shadows_sun_cascades, "rendershadowssuncascadestip")
		tab_next()

		tab_control_menu()
		draw_button_menu("rendershadowssunbuffersize", e_menu.LIST, dx, dy, dw, 24, rendererset.shadows_sun_buffer_size, text_get("rendershadowsbuffersize" + string(rendererset.shadows_sun_buffer_size)) + " (" + string(rendererset.shadows_sun_buffer_size) + "x" + string(rendererset.shadows_sun_buffer_size) + ")", action_project_render_shadows_sun_buffer_size)
		tab_next()
		
		tab_control_menu()
		draw_button_menu("rendershadowsspotbuffersize", e_menu.LIST, dx, dy, dw, 24, rendererset.shadows_spot_buffer_size, text_get("rendershadowsbuffersize" + string(rendererset.shadows_spot_buffer_size)) + " (" + string(rendererset.shadows_spot_buffer_size) + "x" + string(rendererset.shadows_spot_buffer_size) + ")", action_project_render_shadows_spot_buffer_size)
		tab_next()
		
		tab_control_menu()
		draw_button_menu("rendershadowspointbuffersize", e_menu.LIST, dx, dy, dw, 24, rendererset.shadows_point_buffer_size, text_get("rendershadowsbuffersize" + string(rendererset.shadows_point_buffer_size)) + " (" + string(rendererset.shadows_point_buffer_size) + "x" + string(rendererset.shadows_point_buffer_size) + ")", action_project_render_shadows_point_buffer_size)
		tab_next()
		
		if (renderer_edit = e_renderer.STANDARD)
		{
			tab_control_meter()
			draw_meter("rendershadowsblurquality", dx, dy, dw, rendererset.shadows_blur_quality, 0, 64, 20, 1, tab.render.tbx_shadows_blur_quality, action_project_render_shadows_blur_quality)
			tab_next()
			
			tab_control_meter()
			draw_meter("rendershadowsblursize", dx, dy, dw, round(project_render_shadows_blur_size * 100), 0, 400, 100, 1, tab.render.tbx_shadows_blur_size, action_project_render_shadows_blur_size)
			tab_next()
		}
		if (renderer_edit = e_renderer.REALISTIC)
		{
			tab_control_switch()
			draw_switch("rendershadowstransparent", dx, dy, rendererset.shadows_transparent, action_project_render_shadows_transparent)
			tab_next()
		}
		
		tab_collapse_end()
	}
	
	if (renderer_edit = e_renderer.REALISTIC)
	{
		// Subsurface scattering
		tab_control_switch()
		draw_button_collapse("subsurface", collapse_map[?"subsurface"], null, true, "rendersubsurfacescattering", "rendersubsurfacescatteringtip")
		tab_next()
	
		if (collapse_map[?"subsurface"])
		{
			tab_collapse_start()
		
			tab_control_meter()
			draw_meter("rendersubsurfacescatterquality", dx, dy, dw, rendererset.subsurface_samples, 0, 32, 7, 1, tab.render.tbx_subsurface_samples, action_project_render_subsurface_samples)
			tab_next()
		
			tab_control_meter()
			draw_meter("rendersubsurfacescatterhighlight", dx, dy, dw, round(project_render_subsurface_highlight * 100), 0, 100, 50, 1, tab.render.tbx_subsurface_highlight, action_project_render_subsurface_highlight, "rendersubsurfacescatterhighlighttip")
			tab_next()
		
			tab_control_dragger()
			draw_dragger("rendersubsurfacescatterhighlightstrength", dx, dy, dragger_width, round(project_render_subsurface_highlight_strength * 100), .5, 0, no_limit, 100, 1, tab.render.tbx_subsurface_highlight_strength, action_project_render_subsurface_highlight_strength)
			tab_next()
		
			tab_collapse_end()
		}
	
		// Indirect lighting
		tab_control_switch()
		draw_button_collapse("indirect", collapse_map[?"indirect"], action_project_render_indirect, rendererset.indirect, "renderindirect", "renderindirecttip")
		tab_next()
	
		if (rendererset.indirect && collapse_map[?"indirect"])
		{
			tab_collapse_start()
		
			tab_control_meter()
			draw_meter("renderindirectprecision", dx, dy, dw, round(rendererset.indirect_precision * 100), 0, 100, 30, 1, tab.render.tbx_indirect_precision, action_project_render_indirect_precision, "renderindirectprecisiontip")
			tab_next()
		
			tab_control_meter()
			draw_meter("renderindirectblurradius", dx, dy, dw, round(project_render_indirect_blur_radius * 100), 0, 500, 100, 1, tab.render.tbx_indirect_blur_radius, action_project_render_indirect_blur_radius)
			tab_next()
		
			tab_control_dragger()
			draw_dragger("renderindirectstrength", dx, dy, dragger_width, round(project_render_indirect_strength * 100), .5, 0, no_limit * 100, 100, 1, tab.render.tbx_indirect_strength, action_project_render_indirect_strength) 
			tab_next()
		
			tab_collapse_end()
		}
	
		// Reflections
		tab_control_switch()
		draw_button_collapse("reflections", collapse_map[?"reflections"], action_project_render_reflections, rendererset.reflections, "renderreflections")
		tab_next()
	
		if (rendererset.reflections && collapse_map[?"reflections"])
		{
			tab_collapse_start()
		
			tab_control_meter()
			draw_meter("renderreflectionsprecision", dx, dy, dw, round(rendererset.reflections_precision * 100), 0, 100, 30, 1, tab.render.tbx_reflections_precision, action_project_render_reflections_precision, "renderreflectionsprecisiontip")
			tab_next()
		
			tab_control_meter()
			draw_meter("renderreflectionsfadeamount", dx, dy, dw, round(project_render_reflections_fade_amount * 100), 0, 100, 50, 1, tab.render.tbx_reflections_fade_amount, action_project_render_reflections_fade_amount, "renderreflectionsfadeamounttip") 
			tab_next()
		
			tab_control_dragger()
			draw_dragger("renderreflectionsthickness", dx, dy, dragger_width, project_render_reflections_thickness, 1, .1, no_limit, 1, .1, tab.render.tbx_reflections_thickness, action_project_render_reflections_thickness, null, true, false, "renderreflectionsthicknesstip") 
			tab_next()
		
			tab_collapse_end()
		}
	}
	
	// Glow
	tab_control_switch()
	draw_button_collapse("glow", collapse_map[?"glow"], action_project_render_glow, rendererset.glow, "renderglow")
	tab_next()
	
	if (rendererset.glow && collapse_map[?"glow"])
	{
		tab_collapse_start()
		
		tab_control_dragger()
		draw_dragger("renderglowradius", dx, dy, dragger_width, round(project_render_glow_radius * 100), .5, 0, no_limit * 100, 100, 1, tab.render.tbx_glow_radius, action_project_render_glow_radius)
		tab_next()
		
		tab_control_dragger()
		draw_dragger("renderglowintensity", dx, dy, dragger_width, round(project_render_glow_intensity * 100), .5, 0, no_limit * 100, 100, 1, tab.render.tbx_glow_intensity, action_project_render_glow_intensity)
		tab_next()
		
		if (renderer_edit = e_renderer.REALISTIC)
		{
			tab_control_switch()
			draw_button_collapse("glow_falloff", collapse_map[?"glow_falloff"], action_project_render_glow_falloff, rendererset.glow_falloff, "renderglowfalloff")
			tab_next()
		
			// Secondary glow
			if (rendererset.glow_falloff && collapse_map[?"glow_falloff"])
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
		}
		
		tab_collapse_end()
	}
	
	// Glint settings
	tab_control_switch()
	draw_button_collapse("glint", collapse_map[?"glint"], null, true, "renderglint")
	tab_next()
	
	if (collapse_map[?"glint"])
	{
		tab_collapse_start()
		
		tab_control_dragger()
		draw_dragger("renderglintspeed", dx, dy, dragger_width, round(project_render_glint_speed * 100), 1, 0, no_limit, 100, 1, tab.render.tbx_glint_speed, action_project_render_glint_speed)
		tab_next()
	
		tab_control_dragger()
		draw_dragger("renderglintstrength", dx, dy, dragger_width, round(project_render_glint_strength * 100), 1, 0, no_limit, 100, 1, tab.render.tbx_glint_strength, action_project_render_glint_strength)
		tab_next()
		
		tab_collapse_end()
	}
	
	// Light management
	tab_control_switch()
	draw_button_collapse("light_management", collapse_map[?"light_management"], null, true, "renderlightmanagement")
	tab_next()
	
	if (collapse_map[?"light_management"])
	{
		tab_collapse_start()
		
		// Tonemapper
		switch (project_render_tonemapper)
		{
			case e_tonemapper.REINHARD:
				text = text_get("rendertonemapperreinhard")
				break;
			case e_tonemapper.ACES:
				text = text_get("rendertonemapperaces")
				break;
			default:
				text = text_get("rendertonemappernone")
				break;
		}
		
		tab_control_menu()
		draw_button_menu("rendertonemapper", e_menu.LIST, dx, dy, dw, 24, project_render_tonemapper, text, action_project_render_tonemapper)
		tab_next()
		
		// Exposure
		tab_control_dragger()
		draw_dragger("renderexposure", dx, dy, dragger_width, project_render_exposure, 0.01, 0, no_limit, 1, 0.01, tab.render.tbx_exposure, action_project_render_exposure)
		tab_next()
		
		// Gamma
		tab_control_dragger()
		draw_dragger("rendergamma", dx, dy, dragger_width, project_render_gamma, 0.01, 0, no_limit, 2.2, 0.01, tab.render.tbx_gamma, action_project_render_gamma)
		tab_next()
		
		tab_collapse_end()
	}
	
	// AA
	tab_control_switch()
	draw_button_collapse("aa", collapse_map[?"aa"], action_project_render_aa, rendererset.aa, "renderaa", "renderaatip")
	tab_next()
	
	if (rendererset.aa && collapse_map[?"aa"])
	{
		tab_collapse_start()
		
		tab_control_meter()
		draw_meter("renderaapower", dx, dy, dw, round(rendererset.aa_power * 100), 0, 300, 100, 1, tab.render.tbx_aa_power, action_project_render_aa_power)
		tab_next()
		
		tab_collapse_end()
	}
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	#endregion
	#region GRAPHICS
			
	tab_control(16)
	draw_label(text_get("rendergraphics"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_label) 
	tab_next()
	
	// Render distance
	tab_control_dragger()
	draw_dragger("renderdistance", dx, dy, dragger_width, project_render_distance, 1, 1000, 100000, 30000, 1, tab.render.tbx_render_distance, action_project_render_distance, null, true, false, "renderdistancetip")
	tab_next()
	
	// Texture filtering
	tab_control_switch()
	draw_button_collapse("texfilter", collapse_map[?"texfilter"], action_project_render_texture_filtering, project_render_texture_filtering, "rendertexturefiltering", "rendertexturefilteringtip")
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
		draw_meter("rendertexturefilteringlevel", dx, dy, dw, project_render_texture_filtering_level, 0, 5, 1, 1, tab.render.tbx_texture_filtering_level, action_project_render_texture_filtering_level)
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
		
		// Opaque leaves
		tab_control_switch()
		draw_switch("renderopaqueleaves", dx, dy, project_render_opaque_leaves, action_project_render_opaque_leaves)
		tab_next()
		
		// Liquid waves
		tab_control_switch()
		draw_switch("renderliquidanimation", dx, dy, project_render_liquid_animation, action_project_render_liquid_animation)
		tab_next()
		
		tab_collapse_end()
	}
	
	dy += 4
	
	// Alpha mode
	if (renderer_edit = e_renderer.REALISTIC)
	{
		text = (project_render_alpha_mode = e_alpha_mode.BLEND ? text_get("renderalphamodeblend") : text_get("renderalphamodehashed"));
		tab_control_menu()
		draw_button_menu("renderalphamode", e_menu.LIST, dx, dy, dw, 24, project_render_alpha_mode, text, action_project_render_alpha_mode)
		tab_next()
	}
	
	#endregion
	#region MATERIALS
		
	if (renderer_edit = e_renderer.REALISTIC)
	{
		draw_divide(content_x, dy, dividew)
		dy += 12
	
		tab_control(16)
		draw_label(text_get("rendermaterials"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_label)
		tab_next()
	
		// Default emissive
		tab_control_dragger()
		draw_dragger("renderdefaultemissive", dx, dy, dragger_width, round(project_render_block_emissive * 100), 1, 0, no_limit, 100, 1, tab.render.tbx_block_emissive, action_project_render_block_emissive, null, true, false, "renderdefaultemissivetip")
		tab_next()
	
		// Default subsurface
		tab_control_dragger()
		draw_dragger("renderdefaultsubsurfaceradius", dx, dy, dragger_width, project_render_block_subsurface, .1, 0, no_limit, 8, 0.01, tab.render.tbx_block_subsurface_radius, action_project_render_block_subsurface, null, true, false, "renderdefaultsubsurfaceradiustip")
		tab_next()
		
		// Water reflections
		tab_control_switch()
		draw_switch("renderwaterreflections", dx, dy, project_render_water_reflections, action_project_render_water_reflections, "renderwaterreflectionshelp")
		tab_next()
	
		// Material maps
		tab_control_switch()
		draw_switch("rendermaterialmaps", dx, dy, project_render_material_maps, action_project_render_material_maps, "rendermaterialmapstip")
		tab_next()
	
		tab_control(24)
	}
	
	#endregion
}

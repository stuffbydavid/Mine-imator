/// tab_properties_render()

function tab_properties_render()
{
	var text, dividew;
	dividew = content_width - floor(tab.scroll.needed * 12)
	renderer_edit = tab.renderer
	
	draw_tooltip_label("renderrenderertip", icons.INFO, e_toast.INFO)
	
	// Renderer
	tab_control_togglebutton()
	togglebutton_add("renderrendererstandard", setting_theme.dark ? icons.SPHERE_SHADING__DARK : icons.SPHERE_SHADING, e_renderer.STANDARD, renderer_edit = e_renderer.STANDARD, action_project_renderer)
	togglebutton_add("renderrendererrealistic", setting_theme.dark ? icons.SPHERE_MATERIAL__DARK : icons.SPHERE_MATERIAL, e_renderer.REALISTIC, renderer_edit = e_renderer.REALISTIC, action_project_renderer)
	draw_togglebutton("renderrenderer", dx, dy)
	tab_next()
	
	// Renderer presets
	var presetname, presettext;
	presetname = render_preset_map[?project_render_preset[renderer_edit]].name
	
	if (text_exists("renderpreset" + presetname))
		presettext = text_get("renderpreset" + presetname)
	else
		presettext = presetname
	
	tab_control_menu()
	draw_button_menu("renderpreset" + renderer_name_list[renderer_edit], e_menu.LIST, dx, dy, dw, 24, project_render_preset[renderer_edit], presettext, action_project_render_preset)
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
	
	if (renderer_edit = e_renderer.REALISTIC)
	{
		// Render samples
		tab_control_dragger()
		draw_dragger("rendersamples", dx, dy, dragger_width, rendererset.samples, .5, 1, 256, 24, 1, tab.tbx_samples, action_project_render_samples)
		tab_next()
		if (render_performance_warning(render_preset_edit, renderer_edit))
			draw_tooltip_label("renderrendererrealisticwarning", icons.WARNING_TRIANGLE, e_toast.WARNING)
	}
	
	#region SPECIAL EFFECTS

	draw_divide(content_x, dy, dividew)
	dy += 12

	tab_control(16)
	draw_label(text_get("renderspecialeffects"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()


	// SSAO
	tab_control_switch()
	draw_button_collapse("ssao", collapse_map[?"ssao"], action_project_render_ssao, rendererset.ssao, "renderssao", "renderssaotip")
	tab_next()

	if (rendererset.ssao && collapse_map[?"ssao"])
	{
		tab_collapse_start()

		tab_control_dragger()
		draw_dragger("renderssaoradius", dx, dy, dragger_width, project_render_ssao_radius, project_render_ssao_radius / 200, 0, 256, 12, 0.1, tab.tbx_ssao_radius, action_project_render_ssao_radius)
		tab_next()

		tab_control_dragger()
		draw_dragger("renderssaopower", dx, dy, dragger_width, round(project_render_ssao_power * 100), .5, 0, no_limit * 100, 100, 1, tab.tbx_ssao_power, action_project_render_ssao_power)
		tab_next()

		tab_control_meter()
		draw_meter("renderssaoblurpasses", dx, dy, dw, project_render_ssao_blur_passes, 0, 8, 2, 1, tab.tbx_ssao_blur_passes, action_project_render_ssao_blur_passes)
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
		draw_meter("rendershadowssuncascades", dx, dy, dw, rendererset.shadows_sun_cascades, 1, 3, 2, 1, tab.tbx_shadows_sun_cascades, action_project_render_shadows_sun_cascades, "rendershadowssuncascadestip")
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
			draw_meter("rendershadowsblurquality", dx, dy, dw, rendererset.shadows_blur_quality, 0, 64, 20, 1, tab.tbx_shadows_blur_quality, action_project_render_shadows_blur_quality)
			tab_next()
		}

		if (renderer_edit = e_renderer.REALISTIC)
		{
			tab_control_switch()
			draw_switch("rendershadowstransparent", dx, dy, rendererset.shadows_transparent, action_project_render_shadows_transparent)
			tab_next()

			tab_control_switch()
			draw_switch("rendershadowsjittered", dx, dy, rendererset.shadows_jittered, action_project_render_shadows_jittered)
			tab_next()

			if (!rendererset.shadows_jittered)
			{
				tab_control_meter()
				draw_meter("rendershadowsblurquality", dx, dy, dw, rendererset.shadows_blur_quality, 0, 64, 20, 1, tab.tbx_shadows_blur_quality, action_project_render_shadows_blur_quality)
				tab_next()
			}
		}

		tab_control_meter()
		draw_meter("rendershadowsblursize", dx, dy, dw, round(project_render_shadows_blur_size * 100), 0, 400, 100, 1, tab.tbx_shadows_blur_size, action_project_render_shadows_blur_size)
		tab_next()

		tab_collapse_end()
	}

	if (renderer_edit = e_renderer.STANDARD || renderer_edit = e_renderer.REALISTIC)
	{
		// Subsurface scattering
		tab_control_switch()
		draw_button_collapse("subsurface", collapse_map[?"subsurface"], null, true, "rendersubsurfacescattering", "rendersubsurfacescatteringtip")
		tab_next()

		if (collapse_map[?"subsurface"])
		{
			tab_collapse_start()

			if (renderer_edit = e_renderer.REALISTIC)
			{
				tab_control_meter()
				draw_meter("rendersubsurfacescatterquality", dx, dy, dw, rendererset.subsurface_samples, 0, 32, 7, 1, tab.tbx_subsurface_samples, action_project_render_subsurface_samples)
				tab_next()
			}

			tab_control_meter()
			draw_meter("rendersubsurfacescatterbacklightspread", dx, dy, dw, round(project_render_subsurface_backlight_spread * 100), 0, 100, 50, 1, tab.tbx_subsurface_backlight_spread, action_project_render_subsurface_backlight_spread, "rendersubsurfacescatterbacklightspreadtip")
			tab_next()

			tab_control_dragger()
			draw_dragger("rendersubsurfacescatterbacklightstrength", dx, dy, dragger_width, round(project_render_subsurface_backlight_strength * 100), .5, 0, no_limit, 100, 1, tab.tbx_subsurface_backlight_strength, action_project_render_subsurface_backlight_strength)
			tab_next()

			tab_control_switch()
			draw_switch("rendersubsurfacescatterbrightbacklight", dx, dy, project_render_subsurface_bright_backlight, action_project_render_subsurface_bright_backlight, "rendersubsurfacescatterbrightbacklighttip")
			tab_next()

			tab_collapse_end()
		}
	}

	if (renderer_edit = e_renderer.REALISTIC)
	{
		// Indirect lighting
		tab_control_switch()
		draw_button_collapse("indirect", collapse_map[?"indirect"], action_project_render_indirect, rendererset.indirect, "renderindirect", "renderindirecttip")
		tab_next()

		if (rendererset.indirect && collapse_map[?"indirect"])
		{
			tab_collapse_start()

			tab_control_meter()
			draw_meter("renderindirectprecision", dx, dy, dw, round(rendererset.indirect_precision * 100), 0, 100, 30, 1, tab.tbx_indirect_precision, action_project_render_indirect_precision, "renderindirectprecisiontip")
			tab_next()

			tab_control_meter()
			draw_meter("renderindirectblurradius", dx, dy, dw, round(project_render_indirect_blur_radius * 100), 0, 500, 100, 1, tab.tbx_indirect_blur_radius, action_project_render_indirect_blur_radius)
			tab_next()

			tab_control_dragger()
			draw_dragger("renderindirectstrength", dx, dy, dragger_width, round(project_render_indirect_strength * 100), .5, 0, no_limit * 100, 100, 1, tab.tbx_indirect_strength, action_project_render_indirect_strength)
			tab_next()

			tab_control_dragger()
			draw_dragger("renderindirectbounces", dx, dy, dragger_width, rendererset.indirect_bounces, .5, 1, 8, 1, 1, tab.tbx_indirect_bounces, action_project_render_indirect_bounces, null, true, false, "renderindirectbouncestip")
			tab_next()

			var resolutiontext = text_get("renderresolutioneighth")
			switch (rendererset.indirect_resolution * 100)
			{
				case 100: resolutiontext = text_get("renderresolutionfull") break
				case 50: resolutiontext = text_get("renderresolutionhalf") break
				case 25: resolutiontext = text_get("renderresolutionquarter") break
			}

			tab_control_menu()
			draw_button_menu("renderindirectresolution", e_menu.LIST, dx, dy, dw, 24, rendererset.indirect_resolution, resolutiontext, action_project_render_indirect_resolution)
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
			draw_meter("renderreflectionsprecision", dx, dy, dw, round(rendererset.reflections_precision * 100), 0, 100, 30, 1, tab.tbx_reflections_precision, action_project_render_reflections_precision, "renderreflectionsprecisiontip")
			tab_next()

			tab_control_meter()
			draw_meter("renderreflectionsfadeamount", dx, dy, dw, round(project_render_reflections_fade_amount * 100), 0, 100, 50, 1, tab.tbx_reflections_fade_amount, action_project_render_reflections_fade_amount, "renderreflectionsfadeamounttip")
			tab_next()

			tab_control_dragger()
			draw_dragger("renderreflectionsthickness", dx, dy, dragger_width, project_render_reflections_thickness, 1, .1, no_limit, 1, .1, tab.tbx_reflections_thickness, action_project_render_reflections_thickness, null, true, false, "renderreflectionsthicknesstip")
			tab_next()

			tab_control_dragger()
			draw_dragger("renderreflectionsbounces", dx, dy, dragger_width, rendererset.reflections_bounces, .5, 1, 8, 1, 1, tab.tbx_reflections_bounces, action_project_render_reflections_bounces, null, true, false, "renderreflectionsbouncestip")
			tab_next()

			var resolutiontext = text_get("renderresolutioneighth")
			switch (rendererset.reflections_resolution * 100)
			{
				case 100: resolutiontext = text_get("renderresolutionfull") break
				case 50: resolutiontext = text_get("renderresolutionhalf") break
				case 25: resolutiontext = text_get("renderresolutionquarter") break
			}

			tab_control_menu()
			draw_button_menu("renderreflectionsresolution", e_menu.LIST, dx, dy, dw, 24, rendererset.reflections_resolution, resolutiontext, action_project_render_reflections_resolution)
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
		draw_dragger("renderglowradius", dx, dy, dragger_width, round(project_render_glow_radius * 100), 1, 0, no_limit * 100, 100, 1, tab.tbx_glow_radius, action_project_render_glow_radius)
		tab_next()

		tab_control_dragger()
		draw_dragger("renderglowintensity", dx, dy, dragger_width, round(project_render_glow_intensity * 100), 1, 0, no_limit * 100, 100, 1, tab.tbx_glow_intensity, action_project_render_glow_intensity)
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
			case e_tonemapper.UCHIMURA:
				text = text_get("rendertonemapperuchimura")
				break;
			case e_tonemapper.LOTTES:
				text = text_get("rendertonemapperlottes")
				break;
			case e_tonemapper.HABLE:
				text = text_get("rendertonemapperhable")
				break;
			case e_tonemapper.GT7_CURVE:
				text = text_get("rendertonemappergt7curve")
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
		draw_dragger("renderexposure", dx, dy, dragger_width, project_render_exposure, 0.01, 0, no_limit, 1, 0.01, tab.tbx_exposure, action_project_render_exposure)
		tab_next()

		// Gamma
		tab_control_dragger()
		draw_dragger("rendergamma", dx, dy, dragger_width, project_render_gamma, 0.01, 0, no_limit, 2.2, 0.01, tab.tbx_gamma, action_project_render_gamma)
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

		if (renderer_edit = e_renderer.REALISTIC)
		{
			var aatext = rendererset.aa_mode = e_aa_mode.FXAA ? text_get("renderaamodefxaa") : text_get("renderaamodeprogressive");
			tab_control_menu()
			draw_button_menu("renderaamode", e_menu.LIST, dx, dy, dw, 24, rendererset.aa_mode, aatext, action_project_render_aa_mode)
			tab_next()
		}

		tab_control_meter()
		draw_meter("renderaapower", dx, dy, dw, round(rendererset.aa_power * 100), 0, 300, 100, 1, tab.tbx_aa_power, action_project_render_aa_power)
		tab_next()

		tab_collapse_end()
	}

	// Depth of field
	tab_control_switch()
	draw_button_collapse("render_dof", collapse_map[?"render_dof"], null, true, "renderdof")
	tab_next()

	if (collapse_map[?"render_dof"])
	{
		tab_collapse_start()
		tab_control_meter()
		draw_meter("renderdofquality", dx, dy, dw, rendererset.dof_quality, 8, 64, 16, 1, tab.tbx_dof_quality, action_project_render_dof_quality)
		tab_next()
		if (renderer_edit = e_renderer.STANDARD)
		{
			tab_control_switch()
			draw_switch("renderdofrealisticblur", dx, dy, rendererset.dof_realistic_blur, action_project_render_dof_realistic_blur, "renderdofrealisticblurtip")
			tab_next()
		}
		tab_collapse_end()
	}


	#endregion

	#region GRAPHICS

	draw_divide(content_x, dy, dividew)
	dy += 12

	tab_control(16)
	draw_label(text_get("rendergraphics"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()


	// Render distance
	tab_control_dragger()
	draw_dragger("renderdistance", dx, dy, dragger_width, project_render_distance, 1, 1000, 100000, 30000, 1, tab.tbx_render_distance, action_project_render_distance, null, true, false, "renderdistancetip")
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
		draw_meter("rendertexturefilteringlevel", dx, dy, dw, project_render_texture_filtering_level, 0, 5, 1, 1, tab.tbx_texture_filtering_level, action_project_render_texture_filtering_level)
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

	draw_divide(content_x, dy, dividew)
	dy += 12

	tab_control(16)
	draw_label(text_get("rendermaterials"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()


	// Glint settings
	tab_control_switch()
	draw_button_collapse("glint", collapse_map[?"glint"], null, true, "renderglint")
	tab_next()

	if (collapse_map[?"glint"])
	{
		tab_collapse_start()

		tab_control_dragger()
		draw_dragger("renderglintspeed", dx, dy, dragger_width, round(project_render_glint_speed * 100), 1, 0, no_limit, 100, 1, tab.tbx_glint_speed, action_project_render_glint_speed)
		tab_next()

		tab_control_dragger()
		draw_dragger("renderglintstrength", dx, dy, dragger_width, round(project_render_glint_strength * 100), 1, 0, no_limit, 100, 1, tab.tbx_glint_strength, action_project_render_glint_strength)
		tab_next()

		tab_collapse_end()
	}

	// Default water material
	tab_control_switch()
	draw_button_collapse("water_material", collapse_map[?"water_material"], action_project_render_water_reflections, project_render_water_reflections, "renderwaterreflections", "renderwaterreflectionshelp")
	tab_next()

	if (project_render_water_reflections && collapse_map[?"water_material"])
	{
		tab_collapse_start()

		tab_control_dragger()
		draw_dragger("renderwaterroughness", dx, dy, dragger_width, round(project_render_water_roughness * 100), 1, 0, 100, 0, 1, tab.tbx_water_roughness, action_project_render_water_roughness)
		tab_next()

		tab_control_dragger()
		draw_dragger("renderwaterwavestrength", dx, dy, dragger_width, round(project_render_water_wave_strength * 100), 1, 0, 100, 100, 1, tab.tbx_water_wave_strength, action_project_render_water_wave_strength)
		tab_next()

		tab_control_dragger()
		draw_dragger("renderwaterwavespeed", dx, dy, dragger_width, round(project_render_water_wave_speed * 100), 1, 0, no_limit, 100, 1, tab.tbx_water_wave_speed, action_project_render_water_wave_speed)
		tab_next()

		tab_control_dragger()
		draw_dragger("renderwaterwavescale", dx, dy, dragger_width, round(project_render_water_wave_scale * 100), 1, 1, no_limit, 100, 1, tab.tbx_water_wave_scale, action_project_render_water_wave_scale)
		tab_next()

		tab_control_dragger()
		draw_dragger("renderwaterwavedetail", dx, dy, dragger_width, project_render_water_wave_detail, 1, 1, 8, 6, 1, tab.tbx_water_wave_detail, action_project_render_water_wave_detail)
		tab_next()

		tab_collapse_end()
	}

	// Default emissive
	tab_control_dragger()
	draw_dragger("renderdefaultemissive", dx, dy, dragger_width, round(project_render_block_emissive * 100), 1, 0, no_limit, 100, 1, tab.tbx_block_emissive, action_project_render_block_emissive, null, true, false, "renderdefaultemissivetip")
	tab_next()

	// Default subsurface
	tab_control_dragger()
	draw_dragger("renderdefaultsubsurfaceradius", dx, dy, dragger_width, project_render_block_subsurface, .1, 0, no_limit, 8, 0.01, tab.tbx_block_subsurface_radius, action_project_render_block_subsurface, null, true, false, "renderdefaultsubsurfaceradiustip")
	tab_next()

	// Material maps
	tab_control_switch()
	draw_switch("rendermaterialmaps", dx, dy, project_render_material_maps, action_project_render_material_maps, "rendermaterialmapstip")
	tab_next()

	tab_control(24)


	#endregion
}

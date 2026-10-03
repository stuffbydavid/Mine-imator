function tab_renderer()
{
	var dividew = content_width - floor(tab.scroll.needed * 12);
	renderer_edit = tab.renderer
	
	draw_tooltip_label("render/renderer/tip", icons.INFO, e_toast.INFO)
	
	// Renderer
	tab_control_togglebutton()
	togglebutton_add("render/renderer/standard", setting_theme.dark ? icons.SPHERE_SHADING_DARK : icons.SPHERE_SHADING, e_renderer.STANDARD, renderer_edit = e_renderer.STANDARD, action_project_renderer)
	togglebutton_add("render/renderer/realistic", setting_theme.dark ? icons.SPHERE_MATERIAL_DARK : icons.SPHERE_MATERIAL, e_renderer.REALISTIC, renderer_edit = e_renderer.REALISTIC, action_project_renderer)
	draw_togglebutton("render/renderer", dx, dy)
	tab_next()
	
	// Renderer presets
	var presetname, presettext;
	presetname = render_preset_map[?project_render_preset[renderer_edit]].name
	
	if (text_exists("render/preset/" + presetname))
		presettext = text_get("render/preset/" + presetname)
	else
		presettext = presetname
	
	tab_control_menu()
	draw_button_menu("render/preset_" + renderer_name_list[renderer_edit], e_menu.LIST, dx, dy, dw, 24, project_render_preset[renderer_edit], presettext, action_project_render_preset)
	tab_next()
	
	var presetid, rendererset;
	presetid = project_render_preset[renderer_edit]
	render_preset_edit = render_preset_map[?presetid]
	rendererset = render_preset_edit.renderer[renderer_edit]
	
	tab_control(24)
	
	// Reset render settings
	var setx = dx;
	draw_button_icon("render/reset", setx, dy, 24, 24, false, icons.RESET, action_project_render_preset_reset, render_preset_edit.locked, "tooltip/settings/reset")
	
	setx += 28
	draw_divide_vertical(setx, dy, 24)
	setx += 4
	
	// Import render settings
	if (draw_button_icon("render/import", setx, dy, 24, 24, false, icons.SETTINGS_IMPORT, null, render_preset_edit.locked, "tooltip/settings/import"))
		action_project_render_preset_import()
	setx += 28
	
	// Export render settings
	if (draw_button_icon("render/export", setx, dy, 24, 24, false, icons.SETTINGS_EXPORT, null, false, "tooltip/settings/export"))
		action_project_render_preset_export()
	setx += 28
	
	// Set current render settings as default
	if (draw_button_icon("render/setdefault", setx, dy, 24, 24, false, icons.SETTINGS_SETDEFAULT, null, false, "tooltip/settings/set_default"))
		action_project_render_preset_export(render_default_file)
	setx += 28
	
	if (presetid != "custom")
	{
		if (draw_button_icon("render/unlock", setx, dy, 24, 24, false, render_preset_edit.locked ? icons.LOCK : icons.UNLOCK, null, false, render_preset_edit.locked ? "tooltip/settings/unlock" : "tooltip/settings/lock"))
			render_preset_edit.locked = !render_preset_edit.locked
	}
	tab_next()
	dy += 2
	
	if (renderer_edit = e_renderer.REALISTIC)
	{
		// Render samples
		tab_control_dragger()
		draw_dragger("render/samples", dx, dy, dragger_width, rendererset.samples, .5, 1, 256, 24, 1, tab.tbx_samples, action_project_render_samples)
		tab_next()
		if (render_performance_warning(render_preset_edit, renderer_edit))
			draw_tooltip_label("render/renderer/realistic_warning", icons.WARNING_TRIANGLE, e_toast.WARNING)
	}
	
	#region SPECIAL EFFECTS

	draw_divide(content_x, dy, dividew)
	dy += 12

	tab_control(16)
	draw_label(text_get("render/special_effects"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()


	// SSAO
	tab_control_switch()
	draw_button_collapse("render/ssao", collapse_map[?"render/ssao"], action_project_render_ssao, rendererset.ssao, "render/ssao", "render/ssao_tip")
	tab_next()

	if (rendererset.ssao && collapse_map[?"render/ssao"])
	{
		tab_collapse_start()

		tab_control_dragger()
		draw_dragger("render/ssao/radius", dx, dy, dragger_width, project_render_ssao_radius, project_render_ssao_radius / 200, 0, 256, 12, 0.1, tab.tbx_ssao_radius, action_project_render_ssao_radius)
		tab_next()

		tab_control_dragger()
		draw_dragger("render/ssao/power", dx, dy, dragger_width, round(project_render_ssao_power * 100), .5, 0, no_limit * 100, 100, 1, tab.tbx_ssao_power, action_project_render_ssao_power)
		tab_next()

		tab_control_meter()
		draw_meter("render/ssao/blur_passes", dx, dy, dw, project_render_ssao_blur_passes, 0, 8, 2, 1, tab.tbx_ssao_blur_passes, action_project_render_ssao_blur_passes)
		tab_next()

		tab_control_color()
		draw_button_color("render/ssao/color", dx, dy, dw, project_render_ssao_color, c_black, false, action_project_render_ssao_color)
		tab_next()

		tab_control_switch()
		draw_switch("render/ssao/always_visible", dx, dy, project_render_ssao_always_visible, action_project_render_ssao_always_visible, "render/ssao/always_visible_tip")
		tab_next()

		tab_collapse_end()
	}

	// Shadows
	tab_control_switch()
	draw_button_collapse("render/shadows", collapse_map[?"render/shadows"], action_project_render_shadows, rendererset.shadows, "render/shadows")
	tab_next()

	if (rendererset.shadows && collapse_map[?"render/shadows"])
	{
		tab_collapse_start()

		tab_control_meter()
		draw_meter("render/shadows/sun_cascades", dx, dy, dw, rendererset.shadows_sun_cascades, 1, 3, 2, 1, tab.tbx_shadows_sun_cascades, action_project_render_shadows_sun_cascades, "render/shadows/sun_cascades_tip")
		tab_next()

		tab_control_menu()
		draw_button_menu("render/shadows/sun_buffer_size", e_menu.LIST, dx, dy, dw, 24, rendererset.shadows_sun_buffer_size, text_get("render/shadows/buffer_size_" + string(rendererset.shadows_sun_buffer_size)) + " (" + string(rendererset.shadows_sun_buffer_size) + "x" + string(rendererset.shadows_sun_buffer_size) + ")", action_project_render_shadows_sun_buffer_size)
		tab_next()

		tab_control_menu()
		draw_button_menu("render/shadows/spot_buffer_size", e_menu.LIST, dx, dy, dw, 24, rendererset.shadows_spot_buffer_size, text_get("render/shadows/buffer_size_" + string(rendererset.shadows_spot_buffer_size)) + " (" + string(rendererset.shadows_spot_buffer_size) + "x" + string(rendererset.shadows_spot_buffer_size) + ")", action_project_render_shadows_spot_buffer_size)
		tab_next()

		tab_control_menu()
		draw_button_menu("render/shadows/point_buffer_size", e_menu.LIST, dx, dy, dw, 24, rendererset.shadows_point_buffer_size, text_get("render/shadows/buffer_size_" + string(rendererset.shadows_point_buffer_size)) + " (" + string(rendererset.shadows_point_buffer_size) + "x" + string(rendererset.shadows_point_buffer_size) + ")", action_project_render_shadows_point_buffer_size)
		tab_next()

		if (renderer_edit = e_renderer.STANDARD)
		{
			tab_control_meter()
			draw_meter("render/shadows/blur_quality", dx, dy, dw, rendererset.shadows_blur_quality, 0, 64, 20, 1, tab.tbx_shadows_blur_quality, action_project_render_shadows_blur_quality)
			tab_next()
		}

		if (renderer_edit = e_renderer.REALISTIC)
		{
			tab_control_switch()
			draw_switch("render/shadows/transparent", dx, dy, rendererset.shadows_transparent, action_project_render_shadows_transparent)
			tab_next()

			tab_control_switch()
			draw_switch("render/shadows/jittered", dx, dy, rendererset.shadows_jittered, action_project_render_shadows_jittered)
			tab_next()

			if (!rendererset.shadows_jittered)
			{
				tab_control_meter()
				draw_meter("render/shadows/blur_quality", dx, dy, dw, rendererset.shadows_blur_quality, 0, 64, 20, 1, tab.tbx_shadows_blur_quality, action_project_render_shadows_blur_quality)
				tab_next()
			}
		}

		tab_control_meter()
		draw_meter("render/shadows/blur_size", dx, dy, dw, round(project_render_shadows_blur_size * 100), 0, 400, 100, 1, tab.tbx_shadows_blur_size, action_project_render_shadows_blur_size)
		tab_next()

		tab_collapse_end()
	}

	if (renderer_edit = e_renderer.STANDARD || renderer_edit = e_renderer.REALISTIC)
	{
		// Subsurface scattering
		tab_control_switch()
		draw_button_collapse("render/subsurface", collapse_map[?"render/subsurface"], null, true, "render/subsurface_scattering", "render/subsurface_scattering_tip")
		tab_next()

		if (collapse_map[?"render/subsurface"])
		{
			tab_collapse_start()

			if (renderer_edit = e_renderer.REALISTIC)
			{
				tab_control_meter()
				draw_meter("render/subsurface_scatter/quality", dx, dy, dw, rendererset.subsurface_samples, 0, 32, 7, 1, tab.tbx_subsurface_samples, action_project_render_subsurface_samples)
				tab_next()
			}

			tab_control_meter()
			draw_meter("render/subsurface_scatter/backlight_spread", dx, dy, dw, round(project_render_subsurface_backlight_spread * 100), 0, 100, 50, 1, tab.tbx_subsurface_backlight_spread, action_project_render_subsurface_backlight_spread, "render/subsurface_scatter/backlight_spread_tip")
			tab_next()

			tab_control_dragger()
			draw_dragger("render/subsurface_scatter/backlight_strength", dx, dy, dragger_width, round(project_render_subsurface_backlight_strength * 100), .5, 0, no_limit, 100, 1, tab.tbx_subsurface_backlight_strength, action_project_render_subsurface_backlight_strength)
			tab_next()

			tab_control_switch()
			draw_switch("render/subsurface_scatter/bright_backlight", dx, dy, project_render_subsurface_bright_backlight, action_project_render_subsurface_bright_backlight, "render/subsurface_scatter/bright_backlight_tip")
			tab_next()

			tab_collapse_end()
		}
	}

	if (renderer_edit = e_renderer.REALISTIC)
	{
		// Indirect lighting
		tab_control_switch()
		draw_button_collapse("render/indirect", collapse_map[?"render/indirect"], action_project_render_indirect, rendererset.indirect, "render/indirect", "render/indirect_tip")
		tab_next()

		if (rendererset.indirect && collapse_map[?"render/indirect"])
		{
			tab_collapse_start()

			tab_control_meter()
			draw_meter("render/indirect/precision", dx, dy, dw, round(rendererset.indirect_precision * 100), 0, 100, 30, 1, tab.tbx_indirect_precision, action_project_render_indirect_precision, "render/indirect/precision_tip")
			tab_next()

			tab_control_meter()
			draw_meter("render/indirect/blur_radius", dx, dy, dw, round(project_render_indirect_blur_radius * 100), 0, 500, 100, 1, tab.tbx_indirect_blur_radius, action_project_render_indirect_blur_radius)
			tab_next()

			tab_control_dragger()
			draw_dragger("render/indirect/strength", dx, dy, dragger_width, round(project_render_indirect_strength * 100), .5, 0, no_limit * 100, 100, 1, tab.tbx_indirect_strength, action_project_render_indirect_strength)
			tab_next()

			tab_control_dragger()
			draw_dragger("render/indirect/bounces", dx, dy, dragger_width, rendererset.indirect_bounces, .5, 1, 8, 1, 1, tab.tbx_indirect_bounces, action_project_render_indirect_bounces)
			tab_next()

			var resolutiontext = text_get("render/resolution_eighth");
			switch (rendererset.indirect_resolution * 100)
			{
				case 100: resolutiontext = text_get("render/resolution_full"); break
				case 50:  resolutiontext = text_get("render/resolution_half"); break
				case 25:  resolutiontext = text_get("render/resolution_quarter"); break
			}

			tab_control_menu()
			draw_button_menu("render/indirect/resolution", e_menu.LIST, dx, dy, dw, 24, rendererset.indirect_resolution, resolutiontext, action_project_render_indirect_resolution)
			tab_next()

			tab_collapse_end()
		}

		// Reflections
		tab_control_switch()
		draw_button_collapse("render/reflections", collapse_map[?"render/reflections"], action_project_render_reflections, rendererset.reflections, "render/reflections")
		tab_next()

		if (rendererset.reflections && collapse_map[?"render/reflections"])
		{
			tab_collapse_start()

			tab_control_meter()
			draw_meter("render/reflections/precision", dx, dy, dw, round(rendererset.reflections_precision * 100), 0, 100, 30, 1, tab.tbx_reflections_precision, action_project_render_reflections_precision, "render/reflections/precision_tip")
			tab_next()

			tab_control_meter()
			draw_meter("render/reflections/fade_amount", dx, dy, dw, round(project_render_reflections_fade_amount * 100), 0, 100, 50, 1, tab.tbx_reflections_fade_amount, action_project_render_reflections_fade_amount, "render/reflections/fade_amount_tip")
			tab_next()

			tab_control_dragger()
			draw_dragger("render/reflections/thickness", dx, dy, dragger_width, project_render_reflections_thickness, 1, .1, no_limit, 1, .1, tab.tbx_reflections_thickness, action_project_render_reflections_thickness, null, true, false, "render/reflections/thickness_tip")
			tab_next()

			tab_control_dragger()
			draw_dragger("render/reflections/bounces", dx, dy, dragger_width, rendererset.reflections_bounces, .5, 1, 8, 1, 1, tab.tbx_reflections_bounces, action_project_render_reflections_bounces)
			tab_next()

			var resolutiontext = text_get("render/resolution_eighth");
			switch (rendererset.reflections_resolution * 100)
			{
				case 100: resolutiontext = text_get("render/resolution_full"); break
				case 50:  resolutiontext = text_get("render/resolution_half"); break
				case 25:  resolutiontext = text_get("render/resolution_quarter"); break
			}

			tab_control_menu()
			draw_button_menu("render/reflections/resolution", e_menu.LIST, dx, dy, dw, 24, rendererset.reflections_resolution, resolutiontext, action_project_render_reflections_resolution)
			tab_next()

			tab_collapse_end()
		}
	}

	// Glow
	tab_control_switch()
	draw_button_collapse("render/glow", collapse_map[?"render/glow"], action_project_render_glow, rendererset.glow, "render/glow")
	tab_next()

	if (rendererset.glow && collapse_map[?"render/glow"])
	{
		tab_collapse_start()

		tab_control_dragger()
		draw_dragger("render/glow/radius", dx, dy, dragger_width, round(project_render_glow_radius * 100), 1, 0, no_limit * 100, 100, 1, tab.tbx_glow_radius, action_project_render_glow_radius)
		tab_next()

		tab_control_dragger()
		draw_dragger("render/glow/intensity", dx, dy, dragger_width, round(project_render_glow_intensity * 100), 1, 0, no_limit * 100, 100, 1, tab.tbx_glow_intensity, action_project_render_glow_intensity)
		tab_next()

		tab_collapse_end()
	}

	// Light management
	tab_control_switch()
	draw_button_collapse("render/light_management", collapse_map[?"render/light_management"], null, true, "render/light_management")
	tab_next()

	if (collapse_map[?"render/light_management"])
	{
		tab_collapse_start()

		// Tonemapper
		tab_control_menu()
		draw_button_menu("render/tonemapper", e_menu.LIST, dx, dy, dw, 24, project_render_tonemapper, text_get("render/tonemapper/" + render_tonemapper_names[project_render_tonemapper]), action_project_render_tonemapper)
		tab_next()

		// Exposure
		tab_control_dragger()
		draw_dragger("render/exposure", dx, dy, dragger_width, project_render_exposure, 0.01, 0, no_limit, 1, 0.01, tab.tbx_exposure, action_project_render_exposure)
		tab_next()

		// Gamma
		tab_control_dragger()
		draw_dragger("render/gamma", dx, dy, dragger_width, project_render_gamma, 0.01, 0, no_limit, 2.2, 0.01, tab.tbx_gamma, action_project_render_gamma)
		tab_next()

		tab_collapse_end()
	}

	// AA
	tab_control_switch()
	draw_button_collapse("render/aa", collapse_map[?"render/aa"], action_project_render_aa, rendererset.aa, "render/aa", "render/aa_tip")
	tab_next()

	if (rendererset.aa && collapse_map[?"render/aa"])
	{
		tab_collapse_start()

		if (renderer_edit = e_renderer.REALISTIC)
		{
			var aatext = rendererset.aa_mode = e_aa_mode.FXAA ? text_get("render/aa_mode_fxaa") : text_get("render/aa_mode_progressive");
			tab_control_menu()
			draw_button_menu("render/aa_mode", e_menu.LIST, dx, dy, dw, 24, rendererset.aa_mode, aatext, action_project_render_aa_mode)
			tab_next()
		}

		tab_control_meter()
		draw_meter("render/aa_power", dx, dy, dw, round(rendererset.aa_power * 100), 0, 300, 100, 1, tab.tbx_aa_power, action_project_render_aa_power)
		tab_next()

		tab_collapse_end()
	}

	// Depth of field
	tab_control_switch()
	draw_button_collapse("render/render_dof", collapse_map[?"render/render_dof"], null, true, "render/dof")
	tab_next()

	if (collapse_map[?"render/render_dof"])
	{
		tab_collapse_start()
		tab_control_meter()
		draw_meter("render/dof/quality", dx, dy, dw, rendererset.dof_quality, 8, 64, 16, 1, tab.tbx_dof_quality, action_project_render_dof_quality)
		tab_next()
		if (renderer_edit = e_renderer.STANDARD)
		{
			tab_control_switch()
			draw_switch("render/dof/realistic_blur", dx, dy, rendererset.dof_realistic_blur, action_project_render_dof_realistic_blur, "render/dof/realistic_blur_tip")
			tab_next()
		}
		tab_collapse_end()
	}


	#endregion

	#region GRAPHICS

	draw_divide(content_x, dy, dividew)
	dy += 12

	tab_control(16)
	draw_label(text_get("render/graphics"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()


	// Render distance
	tab_control_dragger()
	draw_dragger("render/distance", dx, dy, dragger_width, project_render_distance, 1, 1000, 100000, 30000, 1, tab.tbx_render_distance, action_project_render_distance, null, true, false, "render/distance_tip")
	tab_next()

	// Texture filtering
	tab_control_switch()
	draw_button_collapse("render/texture_filtering", collapse_map[?"render/texture_filtering"], action_project_render_texture_filtering, project_render_texture_filtering, "render/texture_filtering", "render/texture_filtering_tip")
	tab_next()

	if (project_render_texture_filtering && collapse_map[?"render/texture_filtering"])
	{
		tab_collapse_start()

		// Transparent block texture filtering
		tab_control_switch()
		draw_switch("render/texture_filtering/transparent_blocks", dx, dy, project_render_transparent_block_texture_filtering, action_project_render_transparent_block_texture_filtering)
		tab_next()

		// Texture filtering level
		tab_control_meter()
		draw_meter("render/texture_filtering/level", dx, dy, dw, project_render_texture_filtering_level, 0, 5, 1, 1, tab.tbx_texture_filtering_level, action_project_render_texture_filtering_level)
		tab_next()

		tab_collapse_end()
	}

	// Models and scenery
	tab_control_switch()
	draw_button_collapse("render/models_scenery", collapse_map[?"render/models_scenery"], null, true, "render/models_scenery")
	tab_next()

	if (collapse_map[?"render/models_scenery"])
	{
		tab_collapse_start()

		// Bending style
		tab_control_togglebutton()
		togglebutton_add("render/bend_style_realistic", null, "realistic", project_bend_style = "realistic", action_project_render_bend_style)
		togglebutton_add("render/bend_style_blocky", null, "blocky", project_bend_style = "blocky", action_project_render_bend_style)
		draw_togglebutton("render/bend_style", dx, dy)
		tab_next()

		// Opaque leaves
		tab_control_switch()
		draw_switch("render/opaque_leaves", dx, dy, project_render_opaque_leaves, action_project_render_opaque_leaves)
		tab_next()

		// Liquid waves
		tab_control_switch()
		draw_switch("render/liquid_animation", dx, dy, project_render_liquid_animation, action_project_render_liquid_animation)
		tab_next()

		tab_collapse_end()
	}

	// Alpha mode
	if (renderer_edit = e_renderer.REALISTIC)
	{
		content_text = (project_render_alpha_mode = e_alpha_mode.BLEND ? text_get("render/alpha_mode/blend") : text_get("render/alpha_mode/hashed"))
		tab_control_menu()
		draw_button_menu("render/alpha_mode", e_menu.LIST, dx, dy, dw, 24, project_render_alpha_mode, content_text, action_project_render_alpha_mode)
		tab_next()
	}


	#endregion

	#region MATERIALS

	draw_divide(content_x, dy, dividew)
	dy += 12

	tab_control(16)
	draw_label(text_get("render/materials"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()


	// Glint settings
	tab_control_switch()
	draw_button_collapse("render/glint", collapse_map[?"render/glint"], null, true, "render/glint")
	tab_next()

	if (collapse_map[?"render/glint"])
	{
		tab_collapse_start()

		tab_control_dragger()
		draw_dragger("render/glint_speed", dx, dy, dragger_width, round(project_render_glint_speed * 100), 1, 0, no_limit, 100, 1, tab.tbx_glint_speed, action_project_render_glint_speed)
		tab_next()

		tab_control_dragger()
		draw_dragger("render/glint_strength", dx, dy, dragger_width, round(project_render_glint_strength * 100), 1, 0, no_limit, 100, 1, tab.tbx_glint_strength, action_project_render_glint_strength)
		tab_next()

		tab_collapse_end()
	}

	// Default water material
	tab_control_switch()
	draw_button_collapse("render/water_material", collapse_map[?"render/water_material"], action_project_render_water_reflections, project_render_water_reflections, "render/water_reflections", "render/water_reflections_help")
	tab_next()

	if (project_render_water_reflections && collapse_map[?"render/water_material"])
	{
		tab_collapse_start()

		tab_control_dragger()
		draw_dragger("render/water_roughness", dx, dy, dragger_width, round(project_render_water_roughness * 100), 1, 0, 100, 0, 1, tab.tbx_water_roughness, action_project_render_water_roughness)
		tab_next()

		tab_control_dragger()
		draw_dragger("render/water_wave/strength", dx, dy, dragger_width, round(project_render_water_wave_strength * 100), 1, 0, 100, 100, 1, tab.tbx_water_wave_strength, action_project_render_water_wave_strength)
		tab_next()

		tab_control_dragger()
		draw_dragger("render/water_wave/speed", dx, dy, dragger_width, round(project_render_water_wave_speed * 100), 1, 0, no_limit, 100, 1, tab.tbx_water_wave_speed, action_project_render_water_wave_speed)
		tab_next()

		tab_control_dragger()
		draw_dragger("render/water_wave/scale", dx, dy, dragger_width, round(project_render_water_wave_scale * 100), 1, 1, no_limit, 100, 1, tab.tbx_water_wave_scale, action_project_render_water_wave_scale)
		tab_next()

		tab_control_dragger()
		draw_dragger("render/water_wave/detail", dx, dy, dragger_width, project_render_water_wave_detail, 1, 1, 8, 6, 1, tab.tbx_water_wave_detail, action_project_render_water_wave_detail)
		tab_next()

		tab_collapse_end()
	}

	// Default emissive
	tab_control_dragger()
	draw_dragger("render/default_emissive", dx, dy, dragger_width, round(project_render_block_emissive * 100), 1, 0, no_limit, 100, 1, tab.tbx_block_emissive, action_project_render_block_emissive, null, true, false, "render/default_emissive_tip")
	tab_next()

	// Default subsurface
	tab_control_dragger()
	draw_dragger("render/default_subsurface_radius", dx, dy, dragger_width, project_render_block_subsurface, .1, 0, no_limit, 8, 0.01, tab.tbx_block_subsurface_radius, action_project_render_block_subsurface, null, true, false, "render/default_subsurface_radius_tip")
	tab_next()

	// Material maps
	tab_control_switch()
	draw_switch("render/material_maps", dx, dy, project_render_material_maps, action_project_render_material_maps, "render/material_maps_tip")
	tab_next()

	tab_control(24)

	#endregion
}

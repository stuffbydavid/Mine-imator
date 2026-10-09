function tab_timeline_editor_appearance()
{
	if (type_is_light(tl_edit.type))
	{
		tab_set_columns(true, floor(content_width / 150))

		// Shadows
		tab_control_checkbox()
		draw_checkbox("timeline_editor/render_shadows", dx, dy, tl_edit.shadows, action_tl_shadows, "timeline_editor/render_shadows_tip")
		tab_next()

		// Realistic falloff
		if (setting_advanced_mode)
		{
			tab_control_checkbox()
			draw_checkbox("timeline_editor/realistic_falloff", dx, dy, tl_edit.realistic_falloff, action_tl_realistic_falloff, "timeline_editor/realistic_falloff_tip")
			tab_next()
		}

		tab_set_columns(false)
		return 0
	}
	
	if (!setting_advanced_mode)
	{
		// Enchanted
		tab_control_switch()
		draw_switch("timeline_editor/enchanted", dx, dy, tl_edit.glint_enabled, action_tl_glint_enabled)
		tab_next()

		// Glow
		tab_control_switch()
		draw_switch("timeline_editor/glow", dx, dy, tl_edit.glow, action_tl_glow)
		tab_next()
		return 0
	}
	
	// Enchantment glint
	tab_control_switch()
	draw_button_collapse("timeline_editor/glint", collapse_map[?"timeline_editor/glint"], action_tl_glint_enabled, tl_edit.glint_enabled, "timeline_editor/glint")
	tab_next()
	
	if (tl_edit.glint_enabled && collapse_map[?"timeline_editor/glint"])
	{
		tab_collapse_start()
			
		// Enchantment glint
		var tex, glintres;
		glintres = res_eval(tl_edit.glint_tex)
		if (glintres.type = e_res_type.PACK)
		{
			if (tl_edit.glint_mode = e_glint.ARMOR)
				tex = glintres.glint_armor_texture
			else
				tex = glintres.glint_item_texture
		}
		else
			tex = glintres.texture
		
		tab_control_menu(ui_large_height)
		draw_button_menu("timeline_editor/glint/tex", e_menu.LIST, dx, dy, dw, ui_large_height, tl_edit.glint_tex, glintres.display_name, action_tl_glint_tex, false, tex)
		tab_next()
		
		tab_control_togglebutton()
		togglebutton_add("timeline_editor/glint/mode/item", null, e_glint.ITEM, tl_edit.glint_mode = e_glint.ITEM, action_tl_glint_mode)
		togglebutton_add("timeline_editor/glint/mode/armor", null, e_glint.ARMOR, tl_edit.glint_mode = e_glint.ARMOR, action_tl_glint_mode)
		draw_togglebutton("timeline_editor/glint/mode", dx, dy)
		tab_next()
			
		tab_control_dragger()
		draw_dragger("timeline_editor/glint/scale", dx, dy, dragger_width, round(tl_edit.glint_scale * 100), tl_edit.glint_scale, 1, no_limit, 100, 1, tab.appearance.tbx_glint_scale, action_tl_glint_scale)
		tab_next()
			
		tab_control_dragger()
		draw_dragger("timeline_editor/glint/speed", dx, dy, dragger_width, round(tl_edit.glint_speed * 100), tl_edit.glint_speed, 1, no_limit, 100, 1, tab.appearance.tbx_glint_speed, action_tl_glint_speed)
		tab_next()
			
		tab_control_dragger()
		draw_dragger("timeline_editor/glint/strength", dx, dy, dragger_width, round(tl_edit.glint_strength * 100), tl_edit.glint_strength, 1, no_limit, 100, 1, tab.appearance.tbx_glint_strength, action_tl_glint_strength)
		tab_next()
			
		tab_collapse_end()
	}

	// Glow
	tab_control_switch()
	draw_button_collapse("timeline_editor/glow", collapse_map[?"timeline_editor/glow"], action_tl_glow, tl_edit.glow, "timeline_editor/glow")
	tab_next()
	if (tl_edit.glow && collapse_map[?"timeline_editor/glow"])
	{
		tab_collapse_start()
		tab_control_checkbox()
		draw_checkbox("timeline_editor/glow_texture", dx, dy, tl_edit.glow_texture, action_tl_glow_texture)
		tab_next()
		tab_control_checkbox()
		draw_checkbox("timeline_editor/only_render_glow", dx, dy, tl_edit.only_render_glow, action_tl_only_render_glow)
		tab_next()
		tab_collapse_end()
	}

	dy += 8
		
	// Blend mode
	tab_control_menu()
	draw_button_menu("timeline_editor/blend_mode", e_menu.LIST, dx, dy, dw, 24, tl_edit.blend_mode, text_get("timeline_editor/blend_mode/" + tl_edit.blend_mode), action_tl_blend_mode)
	tab_next()
		
	// Alpha mode
	if (tl_edit.alpha_mode = e_alpha_mode.BLEND)
		content_text = text_get("render/alpha_mode/blend")
	else if (tl_edit.alpha_mode = e_alpha_mode.HASHED)
		content_text = text_get("render/alpha_mode/hashed")
	else
		content_text = text_get("render/alpha_mode/default")
			
	tab_control_menu()
	draw_button_menu("timeline_editor/alpha_mode", e_menu.LIST, dx, dy, dw, 24, tl_edit.alpha_mode, content_text, action_tl_alpha_mode, false, null, null, "", null, null, null, "timeline_editor/alpha_mode_tip")
	tab_next()
		
	// Render depth
	tab_control_dragger()
	draw_dragger("timeline_editor/depth", dx, dy, dragger_width, tl_edit.depth, 0.1, -no_limit, no_limit, 0, 1, tab.appearance.tbx_depth, action_tl_depth, null, true, false, "timeline_editor/depth_tip")
	tab_next()
		
	tab_set_columns(true, floor(content_width/150))
		
	// Texture
	tab_control_checkbox()
	draw_checkbox("timeline_editor/texture_blur", dx, dy, tl_edit.texture_blur, action_tl_texture_blur)
	tab_next()
		
	tab_control_checkbox()
	draw_checkbox("timeline_editor/texture_filtering", dx, dy, tl_edit.texture_filtering, action_tl_texture_filtering)
	tab_next()
		
	// Shadows
	tab_control_checkbox()
	draw_checkbox("timeline_editor/shadows", dx, dy, tl_edit.shadows, action_tl_shadows)
	tab_next()
		
	tab_control_checkbox()
	draw_checkbox("timeline_editor/ssao", dx, dy, tl_edit.ssao, action_tl_ssao)
	tab_next()
		
	// Wind
	if (type_has_wind(tl_edit.type))
	{
		tab_control_checkbox()
		draw_checkbox("timeline_editor/wind", dx, dy, tl_edit.wind, action_tl_wind)
		tab_next()
			
		if (tl_edit.type != e_temp_type.TEXT && !type_is_shape(tl_edit.type))
		{
			tab_control_checkbox()
			draw_checkbox("timeline_editor/wind_terrain", dx, dy, tl_edit.wind_terrain, action_tl_wind_terrain)
			tab_next()
		}
	}
	// Fog
	tab_control_checkbox()
	draw_checkbox("timeline_editor/fog", dx, dy, tl_edit.fog, action_tl_fog)
	tab_next()
		
	// Backfaces
	tab_control_checkbox()
	draw_checkbox("timeline_editor/backfaces", dx, dy, tl_edit.backfaces, action_tl_backfaces)
	tab_next()

	tab_set_columns(false)
		
	// Mode visibility
	tab_control_switch()
	draw_button_collapse("timeline_editor/mode_visibility", collapse_map[?"timeline_editor/mode_visibility"], null, true, "timeline_editor/mode_visibility")
	tab_next()
	
	if (collapse_map[?"timeline_editor/mode_visibility"])
	{
		var rendereredit = renderer_edit;

		tab_collapse_start()
		
		tab_control_checkbox()
		renderer_edit = e_renderer.QUICK
		draw_checkbox("timeline_editor/mode_quick", dx, dy, tl_edit.mode_visible[renderer_edit], action_tl_mode_visible)
		tab_next()

		tab_control_checkbox()
		renderer_edit = e_renderer.STANDARD
		draw_checkbox("timeline_editor/mode_standard", dx, dy, tl_edit.mode_visible[renderer_edit], action_tl_mode_visible)
		tab_next()

		tab_control_checkbox()
		renderer_edit = e_renderer.REALISTIC
		draw_checkbox("timeline_editor/mode_realistic", dx, dy, tl_edit.mode_visible[renderer_edit], action_tl_mode_visible)
		tab_next()

		renderer_edit = rendereredit
		tab_collapse_end()
	}
	
	if (!tl_edit.mode_visible[view_main.renderer] && (!view_second.show || !tl_edit.mode_visible[view_second.renderer]))
	{
		dy += 8
		draw_tooltip_label("timeline_editor/mode_visibility_tip", icons.INFO, e_toast.INFO)
	}
}

/// tab_settings_render()

// Camera effects
tab_control_checkbox()
draw_checkbox("settingsrendercameraeffects", dx, dy, setting_render_camera_effects, action_setting_render_camera_effects)
tab_next()

if (setting_render_camera_effects)
{
	tab_control_dragger()
	draw_meter("settingsrenderdofquality", dx, dy, dw, setting_render_dof_quality, 50, 1, 5, 3, 1, tab.render.tbx_dof_quality, action_setting_render_dof_quality)
	tab_next()

	dy += 10
}

// SSAO
tab_control_collapse()
draw_collapse("settingsrenderssao", dx, dy, setting_render_ssao, action_setting_render_ssao, setting_collapse_settings_ssao, action_collapse_settings_ssao)
tab_next()

if (setting_render_ssao && setting_collapse_settings_ssao)
{
	dx += 4
	dw -= 4
	
	var capwid = text_caption_width("settingsrenderssaoradius", "settingsrenderssaopower", "settingsrenderssaoblurpasses")
	
	tab_control_dragger()
	draw_dragger("settingsrenderssaoradius", dx, dy, dw, setting_render_ssao_radius, setting_render_ssao_radius / 200, 0, 256, 12, 0, tab.render.tbx_ssao_radius, action_setting_render_ssao_radius, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrenderssaopower", dx, dy, dw, round(setting_render_ssao_power * 100), 50, 0, 500, 100, 1, tab.render.tbx_ssao_power, action_setting_render_ssao_power, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrenderssaoblurpasses", dx, dy, dw, setting_render_ssao_blur_passes, 50, 0, 8, 2, 1, tab.render.tbx_ssao_blur_passes, action_setting_render_ssao_blur_passes, capwid)
	tab_next()
	
	tab_control_color()
	draw_button_color("settingsrenderssaocolor", dx, dy, dw, setting_render_ssao_color, c_black, false, action_setting_render_ssao_color)
	tab_next()
	dy += 10
	
	dx -= 4
	dw += 4
	tab_collapse_end()
}

// Shadows
tab_control_collapse()
draw_collapse("settingsrendershadows", dx, dy, setting_render_shadows, action_setting_render_shadows, setting_collapse_settings_shadows, action_collapse_settings_shadows)
tab_next()

if (setting_render_shadows && setting_collapse_settings_shadows)
{
	dx += 4
	dw -= 4
	
	var capwid = text_caption_width("settingsrendershadowssunbuffersize", 
									"settingsrendershadowsspotbuffersize", 
									"settingsrendershadowspointbuffersize", 
									"settingsrendershadowsblurquality", 
									"settingsrendershadowsblursize")
	
	tab_control(24)
	draw_button_menu("settingsrendershadowssunbuffersize", e_menu.LIST, dx, dy, dw, 24, setting_render_shadows_sun_buffer_size, text_get("settingsrendershadowsbuffersize" + string(setting_render_shadows_sun_buffer_size)) + " (" + string(setting_render_shadows_sun_buffer_size) + "x" + string(setting_render_shadows_sun_buffer_size) + ")", action_setting_render_shadows_sun_buffer_size, null, null, capwid)
	tab_next()
	
	tab_control(24)
	draw_button_menu("settingsrendershadowsspotbuffersize", e_menu.LIST, dx, dy, dw, 24, setting_render_shadows_spot_buffer_size, text_get("settingsrendershadowsbuffersize" + string(setting_render_shadows_spot_buffer_size)) + " (" + string(setting_render_shadows_spot_buffer_size) + "x" + string(setting_render_shadows_spot_buffer_size) + ")", action_setting_render_shadows_spot_buffer_size, null, null, capwid)
	tab_next()
	
	tab_control(24)
	draw_button_menu("settingsrendershadowspointbuffersize", e_menu.LIST, dx, dy, dw, 24, setting_render_shadows_point_buffer_size, text_get("settingsrendershadowsbuffersize" + string(setting_render_shadows_point_buffer_size)) + " (" + string(setting_render_shadows_point_buffer_size) + "x" + string(setting_render_shadows_point_buffer_size) + ")", action_setting_render_shadows_point_buffer_size, null, null, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrendershadowssamples", dx, dy, dw, setting_render_shadows_samples, 50, 1, 256, 16, 1, tab.render.tbx_shadow_samples, action_setting_render_shadows_samples) 
	tab_next()
	
	tab_control_checkbox()
	draw_checkbox("settingsrendershadowssuncolored", dx, dy, setting_render_shadows_sun_colored, action_setting_render_shadows_sun_colored) 
	tab_next()
	
	dx -= 4
	dw += 4
	tab_collapse_end()
}

tab_control_collapse()
draw_collapse("settingsrenderindirect", dx, dy, setting_render_indirect, action_setting_render_indirect, setting_collapse_settings_indirect, action_collapse_settings_indirect)
tab_next()

if (setting_render_indirect && setting_collapse_settings_indirect)
{
	dx += 4
	dw -= 4
	
	var capwid = text_caption_width("settingsrenderindirectquality",
									"settingsrenderindirectblurpasses",
									"settingsrenderindirectstrength", 
									"settingsrenderindirectrange",
									"settingsrenderindirectscatter")
	
	tab_control(24)
	draw_button_menu("settingsrenderindirectquality", e_menu.LIST, dx, dy, dw, 24, setting_render_indirect_quality, text_get("settingsrenderindirectquality" + string(setting_render_indirect_quality)), action_setting_render_indirect_quality, null, null, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrenderindirectblurpasses", dx, dy, dw, setting_render_indirect_blur_passes, 50, 0, 8, 2, 1, tab.render.tbx_indirect_blur_passes, action_setting_render_indirect_blur_passes, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrenderindirectstrength", dx, dy, dw, round(setting_render_indirect_strength * 100), 50, 0, 1000, 150, 1, tab.render.tbx_indirect_strength, action_setting_render_indirect_strength, capwid) 
	tab_next()
	
	tab_control_dragger()
	draw_dragger("settingsrenderindirectrange", dx, dy, dw, setting_render_indirect_range, setting_render_indirect_range / 200, 1, no_limit, 256, 1, tab.render.tbx_indirect_range, action_setting_render_indirect_range, capwid) 
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrenderindirectscatter", dx, dy, dw, round(setting_render_indirect_scatter * 100), 50, 0, 100, 100, 1, tab.render.tbx_indirect_scatter, action_setting_render_indirect_scatter, capwid) 
	tab_next()
	
	dx -= 4
	dw += 4
	tab_collapse_end()
}

// Glow
tab_control_collapse()
draw_collapse("settingsrenderglow", dx, dy, setting_render_glow, action_setting_render_glow, setting_collapse_settings_glow, action_collapse_settings_glow)
tab_next()

if (setting_render_glow && setting_collapse_settings_glow)
{
	dx += 4
	dw -= 4
	
	var capwid = text_caption_width("settingsrenderglowradius", 
									"settingsrenderglowintensity")
	
	tab_control_meter()
	draw_meter("settingsrenderglowradius", dx, dy, dw, round(setting_render_glow_radius * 100), 50, 0, 300, 100, 1, tab.render.tbx_glow_radius, action_setting_render_glow_radius, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrenderglowintensity", dx, dy, dw, round(setting_render_glow_intensity * 100), 50, 0, 300, 100, 1, tab.render.tbx_glow_intensity, action_setting_render_glow_intensity, capwid)
	tab_next()
	
	tab_control_checkbox()
	draw_checkbox("settingsrenderglowfalloff", dx, dy, setting_render_glow_falloff, action_setting_render_glow_falloff)
	tab_next()
	
	if (setting_render_glow_falloff)
	{
		capwid = text_caption_width("settingsrenderglowfalloffradius", 
									"settingsrenderglowfalloffintensity")
		
		tab_control_meter()
		draw_meter("settingsrenderglowfalloffradius", dx, dy, dw, round(setting_render_glow_falloff_radius * 100), 50, 0, 300, 200, 1, tab.render.tbx_glow_falloff_radius, action_setting_render_glow_falloff_radius, capwid)
		tab_next()
	
		tab_control_meter()
		draw_meter("settingsrenderglowfalloffintensity", dx, dy, dw, round(setting_render_glow_falloff_intensity * 100), 50, 0, 300, 100, 1, tab.render.tbx_glow_falloff_intensity, action_setting_render_glow_falloff_intensity, capwid)
		tab_next()
	}
	
	dx -= 4
	dw += 4
	tab_collapse_end()
}

// AA
tab_control_collapse()
draw_collapse("settingsrenderaa", dx, dy, setting_render_aa, action_setting_render_aa, setting_collapse_settings_aa, action_collapse_settings_aa)
tab_next()

if (setting_render_aa && setting_collapse_settings_aa)
{
	dx += 4
	dw -= 4
	
	tab_control_meter()
	draw_meter("settingsrenderaapower", dx, dy, dw, round(setting_render_aa_power * 100), 48, 0, 300, 100, 1, tab.render.tbx_aa_power, action_setting_render_aa_power)
	tab_next()
	
	dx -= 4
	dw += 4
	tab_collapse_end()
}

// Watermark
if (trial_version)
{
	tab_control_checkbox()
	draw_checkbox("settingsrenderwatermark", dx, dy, setting_render_watermark, action_setting_render_watermark)
}
else
{
	tab_control_collapse()
	draw_collapse("settingsrenderwatermark", dx, dy, setting_render_watermark, action_setting_render_watermark, setting_collapse_settings_watermark, action_collapse_settings_watermark)
}

tab_next()

if (setting_render_watermark)
{
	
	if (!trial_version && setting_collapse_settings_watermark)
	{
		dx += 4
		dw -= 4
		
		var capwid = text_caption_width("settingsrenderwatermarkpositionx", 
									"settingsrenderwatermarkpositiony", 
									"settingsrenderwatermarkscale", 
									"settingsrenderwatermarkalpha", 
									"settingswatermarkimage")
		
		// Watermark Image
		tab_control(18)
		var fn = ((setting_render_watermark_filename = "") ? text_get("settingsrenderwatermarkdefault") : setting_render_watermark_filename);
		draw_label(text_get("settingsrenderwatermarkimage") + ":", dx, dy)
		draw_label(string_limit(fn, dw - capwid), dx + capwid, dy)
		tip_wrap = false
		tip_set(fn, dx, dy, capwid + string_width(fn), 16)
		tab_next()

		tab_control(24)

		if (draw_button_normal("settingswatermarkopen", dx, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.BROWSE))
			action_setting_render_watermark_open()
	
		if (draw_button_normal("settingswatermarkreset", dx + 25, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.RESET))
			action_setting_render_watermark_reset()
	
		tab_next()
		
		// X Position
		tab_control(24)
		draw_button_menu("settingsrenderwatermarkpositionx", e_menu.LIST, dx, dy, dw, 24, setting_render_watermark_anchor_x, text_get("settingsrenderwatermark" + setting_render_watermark_anchor_x), action_setting_render_watermark_position_x, null, null, capwid)
		tab_next()
		
		// Y Position
		tab_control(24)
		draw_button_menu("settingsrenderwatermarkpositiony", e_menu.LIST, dx, dy, dw, 24, setting_render_watermark_anchor_y, text_get("settingsrenderwatermark" + setting_render_watermark_anchor_y), action_setting_render_watermark_position_y, null, null, capwid)
		tab_next()
		
		// Scale
		tab_control_meter()
		draw_meter("settingsrenderwatermarkscale", dx, dy, dw, round(setting_render_watermark_scale * 100), 48, 0, 1000, 100, 1, tab.render.tbx_watermark_scale, action_setting_render_watermark_scale, capwid)
		tab_next()
		
		// Alpha
		tab_control_meter()
		draw_meter("settingsrenderwatermarkalpha", dx, dy, dw, round(setting_render_watermark_alpha * 100), 48, 0, 100, 100, 1, tab.render.tbx_watermark_alpha, action_setting_render_watermark_alpha, capwid)
		tab_next()
		
		// Preview
		draw_watermark_preview(dx, dy, dw)
		dy += (30 * tab.scroll.needed)
		
		dx -= 4
		dw += 4
		tab_collapse_end()
	}
	else
	{
		if (trial_version)
		{
			var str = string_wrap(text_get("settingsrenderwatermarkupgraderequired"), dw);
			draw_label(str, dx, dy)
			dy += string_height(str)
		}
	}
}

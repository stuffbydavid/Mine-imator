/// tab_settings_render()

tab_control_meter()
draw_meter("settingsrendersamples", dx, dy, dw, setting_render_samples, 50, 1, 256, 16, 1, tab.render.tbx_samples, action_setting_render_samples) 
tab_next()

// Samples tooltip
var text, icon, type;

if (setting_render_samples >= 1 && setting_render_samples <= 8)
{
	text = "settingsrendersamples0"
	icon = icons.CHECK
	type = e_toast.POSITIVE
}

if (setting_render_samples >= 9 && setting_render_samples <= 32)
{
	text = "settingsrendersamples1"
	icon = icons.CHECK
	type = e_toast.POSITIVE
}

if (setting_render_samples >= 33 && setting_render_samples <= 64)
{
	text = "settingsrendersamples2"
	icon = icons.CHECK
	type = e_toast.POSITIVE
}

if (setting_render_samples >= 65 && setting_render_samples <= 128)
{
	text = "settingsrendersamples3"
	icon = icons.ALERT
	type = e_toast.WARNING
}

if (setting_render_samples >= 129 && setting_render_samples <= 256)
{
	text = "settingsrendersamples4"
	icon = icons.WARNING_TRIANGLE
	type = e_toast.NEGATIVE
}

draw_tooltip_label(text, icon, type)

tab_control_meter()
draw_meter("settingsrenderdofquality", dx, dy, dw, setting_render_dof_quality, 50, 1, 5, 3, 1, tab.render.tbx_dof_quality, action_setting_render_dof_quality)
tab_next()

// SSAO
tab_control_switch()
draw_button_collapse("settingsrenderssaoshow", setting_collapse_settings_ssao, action_collapse_settings_ssao, !setting_render_ssao)
draw_switch("settingsrenderssao", dx, dy, setting_render_ssao, action_setting_render_ssao)
tab_next()

if (setting_render_ssao && setting_collapse_settings_ssao)
{
	tab_collapse_start()
	
	tab_control_dragger()
	draw_dragger("settingsrenderssaoradius", dx, dy, dragger_width, setting_render_ssao_radius, setting_render_ssao_radius / 200, 0, 256, 12, 0, tab.render.tbx_ssao_radius, action_setting_render_ssao_radius)
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrenderssaopower", dx, dy, dw, round(setting_render_ssao_power * 100), 50, 0, 500, 100, 1, tab.render.tbx_ssao_power, action_setting_render_ssao_power)
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrenderssaoblurpasses", dx, dy, dw, setting_render_ssao_blur_passes, 50, 0, 8, 2, 1, tab.render.tbx_ssao_blur_passes, action_setting_render_ssao_blur_passes)
	tab_next()
	
	tab_control_color()
	draw_button_color("settingsrenderssaocolor", dx, dy, dw, setting_render_ssao_color, c_black, false, action_setting_render_ssao_color, tab.render.tbx_ssao_color)
	tab_next()
	
	tab_collapse_end()
}

// Shadows
tab_control_switch()
draw_button_collapse("settingsrendershadowsshow", setting_collapse_settings_shadows, action_collapse_settings_shadows, !setting_render_shadows)
draw_switch("settingsrendershadows", dx, dy, setting_render_shadows, action_setting_render_shadows)
tab_next()

if (setting_render_shadows && setting_collapse_settings_shadows)
{
	tab_collapse_start()
	
	tab_control_menu()
	draw_button_menu("settingsrendershadowssunbuffersize", e_menu.LIST, dx, dy, dw, 24, setting_render_shadows_sun_buffer_size, text_get("settingsrendershadowsbuffersize" + string(setting_render_shadows_sun_buffer_size)) + " (" + string(setting_render_shadows_sun_buffer_size) + "x" + string(setting_render_shadows_sun_buffer_size) + ")", action_setting_render_shadows_sun_buffer_size)
	tab_next()
	
	tab_control_menu()
	draw_button_menu("settingsrendershadowsspotbuffersize", e_menu.LIST, dx, dy, dw, 24, setting_render_shadows_spot_buffer_size, text_get("settingsrendershadowsbuffersize" + string(setting_render_shadows_spot_buffer_size)) + " (" + string(setting_render_shadows_spot_buffer_size) + "x" + string(setting_render_shadows_spot_buffer_size) + ")", action_setting_render_shadows_spot_buffer_size)
	tab_next()
	
	tab_control_menu()
	draw_button_menu("settingsrendershadowspointbuffersize", e_menu.LIST, dx, dy, dw, 24, setting_render_shadows_point_buffer_size, text_get("settingsrendershadowsbuffersize" + string(setting_render_shadows_point_buffer_size)) + " (" + string(setting_render_shadows_point_buffer_size) + "x" + string(setting_render_shadows_point_buffer_size) + ")", action_setting_render_shadows_point_buffer_size)
	tab_next()
	
	tab_control_switch()
	draw_switch("settingsrendershadowssuncolored", dx, dy, setting_render_shadows_sun_colored, action_setting_render_shadows_sun_colored) 
	tab_next()
	
	tab_collapse_end()
}

// Global illumination
tab_control_switch()
draw_button_collapse("settingsrenderindirectshow", setting_collapse_settings_indirect, action_collapse_settings_indirect, !setting_render_indirect)
draw_switch("settingsrenderindirect", dx, dy, setting_render_indirect, action_setting_render_indirect)
tab_next()

if (setting_render_indirect && setting_collapse_settings_indirect)
{
	tab_collapse_start()
	
	tab_control_menu()
	draw_button_menu("settingsrenderindirectquality", e_menu.LIST, dx, dy, dw, 24, setting_render_indirect_quality, text_get("settingsrenderindirectquality" + string(setting_render_indirect_quality)), action_setting_render_indirect_quality)
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrenderindirectblurpasses", dx, dy, dw, setting_render_indirect_blur_passes, 50, 0, 8, 2, 1, tab.render.tbx_indirect_blur_passes, action_setting_render_indirect_blur_passes)
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrenderindirectstrength", dx, dy, dw, round(setting_render_indirect_strength * 100), 50, 0, 1000, 150, 1, tab.render.tbx_indirect_strength, action_setting_render_indirect_strength) 
	tab_next()
	
	tab_control_dragger()
	draw_dragger("settingsrenderindirectrange", dx, dy, dragger_width, setting_render_indirect_range, setting_render_indirect_range / 200, 1, no_limit, 256, 1, tab.render.tbx_indirect_range, action_setting_render_indirect_range) 
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrenderindirectscatter", dx, dy, dw, round(setting_render_indirect_scatter * 100), 50, 0, 100, 100, 1, tab.render.tbx_indirect_scatter, action_setting_render_indirect_scatter) 
	tab_next()
	
	tab_collapse_end()
}

// Glow
tab_control_switch()
draw_button_collapse("settingsrenderglowshow", setting_collapse_settings_glow, action_collapse_settings_glow, !setting_render_glow)
draw_switch("settingsrenderglow", dx, dy, setting_render_glow, action_setting_render_glow)
tab_next()

if (setting_render_glow && setting_collapse_settings_glow)
{
	tab_collapse_start()
	
	tab_control_meter()
	draw_meter("settingsrenderglowradius", dx, dy, dw, round(setting_render_glow_radius * 100), 50, 0, 300, 100, 1, tab.render.tbx_glow_radius, action_setting_render_glow_radius)
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrenderglowintensity", dx, dy, dw, round(setting_render_glow_intensity * 100), 50, 0, 300, 100, 1, tab.render.tbx_glow_intensity, action_setting_render_glow_intensity)
	tab_next()
	
	tab_control_switch()
	draw_switch("settingsrenderglowfalloff", dx, dy, setting_render_glow_falloff, action_setting_render_glow_falloff)
	tab_next()
	
	// Secondary glow
	if (setting_render_glow_falloff)
	{
		tab_control_meter()
		draw_meter("settingsrenderglowfalloffradius", dx, dy, dw, round(setting_render_glow_falloff_radius * 100), 50, 0, 300, 200, 1, tab.render.tbx_glow_falloff_radius, action_setting_render_glow_falloff_radius)
		tab_next()
	
		tab_control_meter()
		draw_meter("settingsrenderglowfalloffintensity", dx, dy, dw, round(setting_render_glow_falloff_intensity * 100), 50, 0, 300, 100, 1, tab.render.tbx_glow_falloff_intensity, action_setting_render_glow_falloff_intensity)
		tab_next()
	}
	
	tab_collapse_end()
}

// AA
tab_control_switch()
draw_button_collapse("settingsrenderaashow", setting_collapse_settings_aa, action_collapse_settings_aa, !setting_render_aa)
draw_switch("settingsrenderaa", dx, dy, setting_render_aa, action_setting_render_aa)
tab_next()

if (setting_render_aa && setting_collapse_settings_aa)
{
	tab_collapse_start()
	
	tab_control_meter()
	draw_meter("settingsrenderaapower", dx, dy, dw, round(setting_render_aa_power * 100), 48, 0, 300, 100, 1, tab.render.tbx_aa_power, action_setting_render_aa_power)
	tab_next()
	
	tab_collapse_end()
}

// Watermark
tab_control_switch()

if (!trial_version)
	draw_button_collapse("settingsrenderwatermarkshow", setting_collapse_settings_watermark, action_collapse_settings_watermark, !setting_render_watermark)

draw_switch("settingsrenderwatermark", dx, dy, setting_render_watermark, action_setting_render_watermark)
tab_next()

if (setting_render_watermark)
{
	
	if (!trial_version && setting_collapse_settings_watermark)
	{
		tab_collapse_start()
		
		// Watermark Image
		var fn = ((setting_render_watermark_filename = "") ? text_get("settingsrenderwatermarkdefault") : setting_render_watermark_filename);
		
		tab_control(24)
		draw_label_value(dx, dy, dw - 32, 24, text_get("settingsrenderwatermarkimage"), fn)
		tab_next()
		
		tab_control(24)
		
		if (draw_button_icon("settingsrenderwatermarkopen", dx, dy, 24, 24, false, icons.BROWSE))
			action_setting_render_watermark_open()
		
		if (draw_button_icon("settingsrenderwatermarkreset", dx + 32, dy, 24, 24, false, icons.RESET))
			action_setting_render_watermark_reset()
		
		tab_next()
		
		// X Position
		tab_control_menu()
		draw_button_menu("settingsrenderwatermarkpositionx", e_menu.LIST, dx, dy, dw, 24, setting_render_watermark_anchor_x, text_get("settingsrenderwatermark" + setting_render_watermark_anchor_x), action_setting_render_watermark_position_x)
		tab_next()
		
		// Y Position
		tab_control_menu()
		draw_button_menu("settingsrenderwatermarkpositiony", e_menu.LIST, dx, dy, dw, 24, setting_render_watermark_anchor_y, text_get("settingsrenderwatermark" + setting_render_watermark_anchor_y), action_setting_render_watermark_position_y)
		tab_next()
		
		// Scale
		tab_control_meter()
		draw_meter("settingsrenderwatermarkscale", dx, dy, dw, round(setting_render_watermark_scale * 100), 48, 0, 1000, 100, 1, tab.render.tbx_watermark_scale, action_setting_render_watermark_scale)
		tab_next()
		
		// Alpha
		tab_control_meter()
		draw_meter("settingsrenderwatermarkalpha", dx, dy, dw, round(setting_render_watermark_alpha * 100), 48, 0, 100, 100, 1, tab.render.tbx_watermark_alpha, action_setting_render_watermark_alpha)
		tab_next()
		
		// Preview
		draw_watermark_preview(dx, dy, dw)
		
		tab_collapse_end()
	}
	else
	{
		if (trial_version)
			draw_tooltip_label("settingsrenderwatermarkupgraderequired", icons.UPGRADE, e_toast.INFO)
	}
}

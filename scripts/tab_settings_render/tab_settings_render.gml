/// tab_settings_render()

// SSAO
tab_control_checkbox()
draw_checkbox("settingsrenderssao", dx, dy, setting_render_ssao, action_setting_render_ssao)
tab_next()

if (setting_render_ssao)
{
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
}

// Shadows
tab_control_checkbox()
draw_checkbox("settingsrendershadows", dx, dy, setting_render_shadows, action_setting_render_shadows)
tab_next()

if (setting_render_shadows)
{
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
	draw_meter("settingsrendershadowsblurquality", dx, dy, dw, setting_render_shadows_blur_quality, 48, 1, 64, 20, 1, tab.render.tbx_shadows_blur_quality, action_setting_render_shadows_blur_quality, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("settingsrendershadowsblursize", dx, dy, dw, round(setting_render_shadows_blur_size * 100), 48, 0, 400, 100, 1, tab.render.tbx_shadows_blur_size, action_setting_render_shadows_blur_size, capwid)
	tab_next()
}

// DOF
tab_control_checkbox()
draw_checkbox("settingsrenderdof", dx, dy, setting_render_dof, action_setting_render_dof)
tab_next()

if (setting_render_dof)
{
	tab_control_meter()
	draw_meter("settingsrenderdofblursize", dx, dy, dw, setting_render_dof_blur_size * 100, 48, 0, 10, 2, 0, tab.render.tbx_dof_blur_size, action_setting_render_dof_blur_size)
	tab_next()
}

// AA
tab_control_checkbox()
draw_checkbox("settingsrenderaa", dx, dy, setting_render_aa, action_setting_render_aa)
tab_next()

if (setting_render_aa)
{
	tab_control_meter()
	draw_meter("settingsrenderaapower", dx, dy, dw, round(setting_render_aa_power * 100), 48, 0, 300, 100, 1, tab.render.tbx_aa_power, action_setting_render_aa_power)
	tab_next()
}

// Watermark
tab_control_checkbox()
draw_checkbox("settingsrenderwatermark", dx, dy, setting_render_watermark, action_setting_render_watermark)
tab_next()

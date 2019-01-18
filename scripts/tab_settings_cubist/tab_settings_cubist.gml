//tab_settings_cubist()

// Platform selector
if(cubist_get_platform_count() > 0) {
	tab_control(24)
	draw_button_menu("settingscubistplatform", e_menu.LIST, dx, dy, dw, 24, setting_cubist_platform, cubist_get_platform_name(setting_cubist_platform), action_setting_cubist_platform)
	tab_next()
	dy += 10

	// Device selector
	if(cubist_get_device_count() > 0) {
		tab_control(24)
		draw_button_menu("settingscubistdevice", e_menu.LIST, dx, dy, dw, 24, setting_cubist_device, cubist_get_device_name(setting_cubist_device), action_setting_cubist_device)
		tab_next()
		dy += 10
		
		
		tab_control_checkbox_expand()
		draw_checkbox_expand("settingscubistao", dx, dy, setting_cubist_ao, action_setting_cubist_ao, checkbox_expand_setting_cubist_ao, action_checkbox_expand_cubist_ao)
		tab_next();
		
		if(setting_cubist_ao && checkbox_expand_setting_cubist_ao){
			dx += 4
			dw -= 4
			
			tab_control_dragger()
			draw_dragger("settingscubistaostrength", dx, dy, dw, setting_cubist_ao_strength, 1, 0, 1, 0, 0,tab.cubist.tbx_ao_strength, action_setting_cubist_ao_strength)
			tab_next();
			
			dx -= 4
			dw += 4
		}
		
		
		
	}
	else {
		tab_control(24)
		draw_label("settingscubisterrornodevice", dx, dy);
		tab_next();
	}

}else {
	tab_control(24)
	draw_label("settingscubisterrornodevice", dx, dy);
	tab_next();
}
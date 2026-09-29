function action_setting_camera_lock_mouse(enabled)
{
	if (enabled && platform_get() = e_platform.MAC_OS && !show_question(text_get("settingscameralockmousemessage")))
		return 0
	
	setting_camera_lock_mouse = enabled
	window_mouse_set_permission(enabled)
	
	// Trigger Mac OS security message
	if (enabled)
		display_mouse_set(display_mouse_get_x() + 1, display_mouse_get_y())
}

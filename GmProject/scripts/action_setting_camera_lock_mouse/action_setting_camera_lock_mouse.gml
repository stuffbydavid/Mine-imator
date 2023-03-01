/// action_setting_camera_lock_mouse(yes)
/// @arg yes
function action_setting_camera_lock_mouse(val) {

	if (val && platform_get() = e_platform.MAC_OS && !show_question(text_get("settingscameralockmousemessage")))
		return 0;
		
	setting_camera_lock_mouse = val
	window_mouse_set_permission(val)

	// Trigger Mac OS security message
	if (val)
		display_mouse_set(display_mouse_get_x() + 1, display_mouse_get_y())
}

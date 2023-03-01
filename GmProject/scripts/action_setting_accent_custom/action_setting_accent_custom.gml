/// action_setting_accent_custom(color)
/// @arg color

function action_setting_accent_custom(color)
{
	setting_accent = 9
	setting_accent_custom = color
	update_interface_timeout = current_time + 10000
	update_interface_wait = true
}

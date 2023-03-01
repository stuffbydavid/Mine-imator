/// action_setting_theme(theme)
/// @arg theme

function action_setting_theme(theme)
{
	setting_theme = theme
	update_interface_timeout = current_time + 10000
	update_interface_wait = true
}

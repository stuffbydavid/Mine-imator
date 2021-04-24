/// action_setting_render_watermark(enable)
/// @arg enable

function action_setting_render_watermark(enable)
{
	if (trial_version)
		popup_show(popup_upgrade)
	else
		setting_render_watermark = enable
}

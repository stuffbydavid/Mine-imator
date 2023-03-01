/// action_setting_watermark_custom(custom)
/// @arg custom

function action_setting_watermark_custom(custom)
{
	if (trial_version)
	{
		popup_show(popup_upgrade)
		popup_upgrade.page = 0
		return 0
	}
	
	setting_watermark_custom = custom
}

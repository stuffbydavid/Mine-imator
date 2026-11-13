function action_toolbar_export_watermark()
{
	if (trial_version)
	{
		popup_switch(popup_upgrade)
		popup_upgrade.page = 0
		return 0
	}
	
	popup_current.watermark = !popup_current.watermark
}

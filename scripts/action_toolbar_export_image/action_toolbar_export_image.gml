/// action_toolbar_export_image()

function action_toolbar_export_image()
{
	if (trial_version)
	{
		toast_new(e_toast.WARNING, text_get("alerttrial"))
		toast_add_action("alerttrialupgrade", popup_switch, popup_upgrade)
		toast_last.dismiss_time = no_limit
	}
	
	popup_show(popup_exportimage)
}

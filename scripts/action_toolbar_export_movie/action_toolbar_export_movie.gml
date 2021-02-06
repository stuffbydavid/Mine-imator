/// action_toolbar_export_movie()

if (trial_version)
{
	toast_new(e_toast.WARNING, text_get("alerttrial"))
	toast_add_action("alerttrialupgrade", popup_switch, popup_upgrade)
}

popup_show(popup_exportmovie)

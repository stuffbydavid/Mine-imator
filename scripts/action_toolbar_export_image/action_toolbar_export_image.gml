/// action_toolbar_export_image()

if (trial_version)
	alert_show(text_get("alerttrialtitle"), text_get("alerttrialtext"), icons.UPGRADE_SMALL, "alerttrialbutton", "", 5000)

popup_show(popup_exportimage)

/// action_toolbar_export_movie()

if (trial_version)
	alert_show(text_get("alerttrialtitle"), text_get("alerttrialtext"), icons.upgradesmall, "alerttrialbutton", "", 5000)

popup_show(popup_exportmovie)

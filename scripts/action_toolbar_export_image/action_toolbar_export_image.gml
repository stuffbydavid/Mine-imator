/// action_toolbar_export_image()

if (trial_version)
    alert_show(text_get("alerttrialtitle"), text_get("alerttrialtext"), icons.upgradesmall, "alerttrialbutton", "", 5000)

popup_show(popup_exportimage)

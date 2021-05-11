/// action_toolbar_exportimage_watermark()

function action_toolbar_exportimage_watermark()
{
	if (trial_version)
		popup_switch(popup_upgrade)
	else
		popup_exportimage.watermark = !popup_exportimage.watermark
}

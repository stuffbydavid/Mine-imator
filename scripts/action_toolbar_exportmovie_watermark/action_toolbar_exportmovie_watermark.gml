/// action_toolbar_exportmovie_watermark()

function action_toolbar_exportmovie_watermark()
{
	if (trial_version)
		popup_switch(popup_upgrade)
	else
		popup.watermark = !popup.watermark
}

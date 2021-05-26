/// action_setting_watermark_reset()

function action_setting_watermark_reset()
{
	if (setting_watermark_filename != "")
	{
		setting_watermark_image = spr_watermark
		setting_watermark_filename = ""
	}
}

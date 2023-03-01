/// action_setting_watermark_reset()

function action_setting_watermark_reset()
{
	file_delete_lib(setting_watermark_fn)
	setting_watermark_fn = ""
	
	sprite_delete(setting_watermark_image)
	setting_watermark_image = null
}

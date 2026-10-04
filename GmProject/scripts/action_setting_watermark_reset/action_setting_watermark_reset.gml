function action_setting_watermark_reset()
{
	file_delete_lib(setting_watermark_fn)
	setting_watermark_fn = ""
	
	texture_free(setting_watermark_image)
	setting_watermark_image = null
}

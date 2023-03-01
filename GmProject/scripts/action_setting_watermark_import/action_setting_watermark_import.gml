/// action_setting_watermark_import()

function action_setting_watermark_import()
{
	var fn = file_dialog_open_image();
	
	if (fn = "")
		return 0
	
	setting_watermark_fn = data_directory + "watermark" + filename_ext(fn)
	file_copy_lib(fn, setting_watermark_fn)
	setting_watermark_image = texture_create(setting_watermark_fn)
}

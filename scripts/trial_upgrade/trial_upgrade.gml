/// trial_upgrade(key)
/// @arg key

function trial_upgrade(argument0)
{
	var key = argument0;
	
	if (!key_valid(key))
		return false
	
	var f = file_text_open_write(temp_file);
	if (f > -1)
	{
		file_text_write_string(f, string(key))
		file_text_close(f)
	}
	file_copy_lib(temp_file, key_file)
	
	trial_version = false
	popup_exportimage.watermark = false
	popup_exportmovie.watermark = false
	settings_save()
	
	toast_new(e_toast.POSITIVE, text_get("alertupgraded"))
	return true
}

/// trial_upgrade(key)
/// @arg key

var key = argument0;

if (!key_valid(key))
{
	error("errorupgrade")
	return false
}

var f = file_text_open_write(temp_file);
if (f > -1)
{
	file_text_write_string(f, string(key))
	file_text_close(f)
}
file_copy_lib(temp_file, key_file)

trial_version = false
setting_render_watermark = false
settings_save()

alert_show(text_get("alertupgradedtitle"), text_get("alertupgradedtext"), icons.upgradesmall, "", "", 5000)

return true

/// action_setting_color_load()

var fn = file_dialog_open_color();

if (!file_exists_lib(fn))
	return 0

if (filename_ext(fn) = ".micolor")
{
	var json, map;
	json = file_text_contents(fn)
	map = json_decode(json)
	settings_load_colors(map[?"colors"])
}

// Legacy
else
{
	buffer_current = buffer_load_lib(fn)
	settings_load_legacy_colors()
	buffer_delete(buffer_current)
}
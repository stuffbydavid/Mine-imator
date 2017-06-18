/// action_setting_font_open()

var fn = file_dialog_open_font();
if (!file_exists_lib(fn))
	return 0

if (setting_font_filename != "")
{
	font_delete(setting_font)
	font_delete(setting_font_bold)
}

setting_font_filename = fn
setting_font = font_import(fn, 12, false, false)
setting_font_bold = font_import(fn, 12, true, false)
setting_font_big = font_import(fn, 18, false, false)

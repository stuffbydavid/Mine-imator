/// action_setting_font_reset()

if (setting_font_filename != "")
{
	font_delete(setting_font)
	font_delete(setting_font_bold)
	setting_font = font_main
	setting_font_bold = font_main_bold
	setting_font_big = font_main_big
	setting_font_filename = ""
}

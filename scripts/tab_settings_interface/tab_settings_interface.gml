/// tab_settings_interface()

var capwid;

// Tips
tab_control_dragger()
draw_checkbox("settingstipshow", dx, dy + 2, setting_tip_show, action_setting_tip_show)
if (setting_tip_show)
{
	tab.interface.tbx_tip_delay.suffix = " " + text_get("settingstipdelayseconds")
	draw_dragger("settingstipdelay", dx + floor(dw * 0.5), dy, dw * 0.5, setting_tip_delay, 0.005, 0, no_limit, 0.25, 0, tab.interface.tbx_tip_delay, action_setting_tip_delay)
}
tab_next()
dy += 10

// View
capwid = text_caption_width("settingsviewgridsizehor") + 15

tab_control_dragger()
draw_dragger("settingsviewgridsizehor", dx, dy, capwid, setting_view_grid_size_hor, 0.05, 1, 10, 3, 1, tab.interface.tbx_view_grid_size_hor, action_setting_view_grid_size_hor)
draw_label("x", dx + capwid, dy + 17, fa_left, fa_bottom)
draw_dragger("settingsviewgridsizever", dx + capwid, dy, dw - capwid, setting_view_grid_size_ver, 0.05, 1, 10, 3, 1, tab.interface.tbx_view_grid_size_ver, action_setting_view_grid_size_ver, 15, text_get("settingsviewgridsizehortip"))
tab_next()

tab_control_checkbox()
draw_checkbox("settingsviewrealtimerender", dx, dy, setting_view_real_time_render, action_setting_view_real_time_render)
tab_next()

if (setting_view_real_time_render)
{
	tab_control_dragger()
	tab.interface.tbx_view_real_time_render_time.suffix = " " + text_get("settingsviewrealtimerendertimemilliseconds")
	draw_dragger("settingsviewrealtimerendertime", dx, dy, dw, setting_view_real_time_render_time, 1, 0, no_limit, 100, 1, tab.interface.tbx_view_real_time_render_time, action_setting_view_real_time_render_time)
	tab_next()
}
dy += 10

// Font
capwid = text_caption_width("settingsfont")

tab_control(18)
var fn = test(setting_font_filename = "", text_get("settingsfontdefault"), setting_font_filename);
draw_label(text_get("settingsfont") + ":", dx, dy)
draw_label(string_limit(fn, dw - capwid), dx + capwid, dy)
tip_wrap = false
tip_set(fn, dx, dy, capwid + string_width(fn), 16)
tab_next()

tab_control(24)

if (draw_button_normal("settingsfontopen", dx, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.browse))
	action_setting_font_open()
	
if (draw_button_normal("settingsfontreset", dx + 25, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.reset))
	action_setting_font_reset()
	
tab_next()
dy += 10

// Language
capwid = text_caption_width("settingslanguagetranslator", "settingslanguageforversion", "settingslanguageforversion", "settingslanguagelastchange")
tab_control(16 * 4)
tip_set(text_get("settingslanguagetip"), dx, dy, dw * 0.5, 18 * 4)

draw_label(text_get("settingslanguage") + ":", dx, dy)
draw_label(text_get("settingslanguagetranslator") + ":", dx, dy + 18 * 1)
draw_label(text_get("settingslanguageforversion") + ":", dx, dy + 18 * 2)
draw_label(text_get("settingslanguagelastchange") + ":", dx, dy + 18 * 3)
draw_label(text_get("filelanguage"), dx + capwid, dy)
draw_label(text_get("filetranslator"), dx + capwid, dy + 18 * 1)
draw_label(text_get("fileforversion"), dx + capwid, dy + 18 * 2)
draw_label(text_get("filelastchange"), dx + capwid, dy + 18 * 3)

tab_next()

tab_control(24)

if (draw_button_normal("settingslanguageload", dx, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.browse))
	action_setting_language_load()
	
if (draw_button_normal("settingslanguagereload", dx + 25, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.reload))
	action_setting_language_reload()
	
tab_next()
dy += 10

// Color
var wid = floor(dw / 2) - 4;

tab_control_color()
draw_button_color("settingscolorinterface", dx, dy, wid, setting_color_interface, c_main, false, action_setting_color_interface)
draw_button_color("settingscolortext", dx + wid + 8, dy, wid, setting_color_text, c_text, false, action_setting_color_text)
tab_next()

tab_control_color()
draw_button_color("settingscolortips", dx, dy, wid, setting_color_tips, c_tips, false, action_setting_color_tips)
draw_button_color("settingscolortipstext", dx + wid + 8, dy, wid, setting_color_tips_text, c_white, false, action_setting_color_tips_text)
tab_next()

tab_control_color()
draw_button_color("settingscolorbuttons", dx, dy, wid, setting_color_buttons, c_secondary, false, action_setting_color_buttons)
draw_button_color("settingscolorbuttonstext", dx + wid + 8, dy, wid, setting_color_buttons_text, c_white, false, action_setting_color_buttons_text)
tab_next()

tab_control_color()
draw_button_color("settingscolorboxes", dx, dy, wid, setting_color_boxes, c_white, false, action_setting_color_boxes)
draw_button_color("settingscolorboxestext", dx + wid + 8, dy, wid, setting_color_boxes_text, c_text, false, action_setting_color_boxes_text)
tab_next()

tab_control_color()
draw_button_color("settingscolorhighlight", dx, dy, wid, setting_color_highlight, c_highlight, false, action_setting_color_highlight)
draw_button_color("settingscolorhighlighttext", dx + wid + 8, dy, wid, setting_color_highlight_text, c_white, false, action_setting_color_highlight_text)
tab_next()

tab_control_color()
draw_button_color("settingscolortimeline", dx, dy, wid, setting_color_timeline, c_white, false, action_setting_color_timeline)
draw_button_color("settingscolortimelinetext", dx + wid + 8, dy, wid, setting_color_timeline_text, c_text, false, action_setting_color_timeline_text)
tab_next()

tab_control_color()
draw_button_color("settingscoloralerts", dx, dy, wid, setting_color_alerts, c_alerts, false, action_setting_color_alerts)
draw_button_color("settingscoloralertstext", dx + wid + 8, dy, wid, setting_color_alerts_text, c_text, false, action_setting_color_alerts_text)
tab_next()

tab_control(24)

if (draw_button_normal("settingscoloropen", dx, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.browse))
	action_setting_color_open()
	
if (draw_button_normal("settingscolorsave", dx + 25, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.export))
	action_setting_color_save()
	
wid = (dw - 54) / 2-2
if (draw_button_normal("settingscolorreset", dx + 54, dy - 2, wid, 28))
	action_setting_color_reset()
	
tab_next()
dy += 10

// Timeline
tab_control_checkbox()
draw_checkbox("settingstimelineautoscroll", dx, dy, setting_timeline_autoscroll, action_setting_timeline_autoscroll)
tab_next()

tab_control_checkbox()
draw_checkbox("settingstimelinecompact", dx, dy, setting_timeline_compact, action_setting_timeline_compact)
tab_next()

tab_control_checkbox()
draw_checkbox("settingstimelineselectjump", dx, dy, setting_timeline_select_jump, action_setting_timeline_select_jump)
tab_next()

// Z is up
tab_control_checkbox()
draw_checkbox("settingszisup", dx, dy, setting_z_is_up, action_setting_z_is_up)
tab_next()

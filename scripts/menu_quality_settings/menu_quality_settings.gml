/// menu_quality_settings()

draw_set_font(font_emphasis)
var capwid = text_max_width("viewmodefog") + 16 + 24;

tab_control_switch()
if (draw_switch("viewmodefog", dx, dy, settings_menu_view.fog, null, true))
	settings_menu_view.fog = !settings_menu_view.fog
tab_next()

settings_menu_w = (capwid + 24)
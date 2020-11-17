/// tab_frame_editor_sound()

var capwid, text;

draw_set_font(font_emphasis)
capwid = text_caption_width("frameeditorsoundstart", "frameeditorsoundend")

if (tl_edit.value[e_value.SOUND_OBJ] != null)
	text = tl_edit.value[e_value.SOUND_OBJ].display_name
else
	text = text_get("listnone")

tab_control_menu(28)
draw_button_menu("frameeditorsound", e_menu.LIST, dx, dy, dw, 28, tl_edit.value[e_value.SOUND_OBJ], text, action_tl_frame_sound_obj)
tab_next()

tab_control_meter()
draw_meter("frameeditorsoundvolume", dx, dy, dw, round(tl_edit.value[e_value.SOUND_VOLUME] * 100), 50, 0, 100, 100, 1, tab.sound.tbx_volume, action_tl_frame_sound_volume, capwid)
tab_next()

tab_control_dragger()
draw_dragger("frameeditorsoundstart", dx, dy, 86, tl_edit.value[e_value.SOUND_START], max(0.01, 0.005 * abs(tl_edit.value[e_value.SOUND_START])), 0, no_limit, 0, 0, tab.sound.tbx_start, action_tl_frame_sound_start, capwid)
draw_label(text_get("frameeditorsoundseconds"), dx + 86 + 16 + capwid, dy + 14, fa_left, fa_middle, c_text_main, a_text_main, font_value)
tab_next()

tab_control_dragger()
draw_dragger("frameeditorsoundend", dx, dy, 86, tl_edit.value[e_value.SOUND_END], max(0.01, 0.005 * abs(tl_edit.value[e_value.SOUND_END])), -no_limit, no_limit, 0, 0, tab.sound.tbx_end, action_tl_frame_sound_end, capwid)
draw_label(text_get("frameeditorsoundseconds"), dx + 86 + 16 + capwid, dy + 14, fa_left, fa_middle, c_text_main, a_text_main, font_value)
tab_next()

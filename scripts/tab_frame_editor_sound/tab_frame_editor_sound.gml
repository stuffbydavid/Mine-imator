/// tab_frame_editor_sound()

var capwid, text;

capwid = text_caption_width("frameeditorsound", "frameeditorvolume", "frameeditorsoundstart", "frameeditorsoundend")

if (tl_edit.value[SOUNDOBJ])
	text = tl_edit.value[SOUNDOBJ].display_name
else
	text = text_get("listnone")
	
tab_control(32)
draw_button_menu("frameeditorsound", e_menu.LIST, dx, dy, dw, 32, tl_edit.value[SOUNDOBJ], text, action_tl_frame_soundobj, null, null, capwid)
tab_next()

tab_control_meter()
draw_meter("frameeditorsoundvolume", dx, dy, dw, round(tl_edit.value[SOUNDVOLUME] * 100), 50, 0, 100, 100, 1, tab.sound.tbx_volume, action_tl_frame_soundvolume, capwid)
tab_next()

tab.sound.tbx_start.suffix = " " + text_get("frameeditorsoundseconds")
tab.sound.tbx_end.suffix = " " + text_get("frameeditorsoundseconds")

tab_control_dragger()
draw_dragger("frameeditorsoundstart", dx, dy, dw, tl_edit.value[SOUNDSTART], max(0.01, 0.005 * abs(tl_edit.value[SOUNDSTART])), 0, no_limit, 0, 0, tab.sound.tbx_start, action_tl_frame_soundstart, capwid)
tab_next()

tab_control_dragger()
draw_dragger("frameeditorsoundend", dx, dy, dw, tl_edit.value[SOUNDEND], max(0.01, 0.005 * abs(tl_edit.value[SOUNDEND])), -no_limit, no_limit, 0, 0, tab.sound.tbx_end, action_tl_frame_soundend, capwid)
tab_next()

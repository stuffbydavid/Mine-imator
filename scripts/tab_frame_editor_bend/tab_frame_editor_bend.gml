/// tab_frame_editor_bend()

var snapval = tab.bend.snap_enabled * tab.bend.snap_size;

tab_control(100)
draw_wheel("frameeditorbendwheel", dx + floor(dw * 0.5), dy + 50, c_green, tl_edit.value[BENDANGLE], -130, 130, 0, snapval, false, tab.bend.tbx_wheel, action_tl_frame_bend_angle, 50, spr_circle_100)
tab_next()

// Tools
tab_control(24)

if (draw_button_normal("frameeditorbendreset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.reset))
	action_tl_frame_bend_angle(0, false)
	
if (draw_button_normal("frameeditorbendcopy", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.copy))
	tab.bend.copy = tl_edit.value[BENDANGLE]
	
if (draw_button_normal("frameeditorbendpaste", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.paste))
	action_tl_frame_bend_angle(tab.bend.copy, false)
	
if (draw_button_normal("frameeditorbendsnap", dx + 25 * 3, dy, 24, 24, e_button.NO_TEXT, tab.bend.snap_enabled, false, true, icons.grid))
	tab.bend.snap_enabled=!tab.bend.snap_enabled
	
if (tab.bend.snap_enabled)
{
	capwid = text_caption_width("frameeditorbendsnapsize")
	if (draw_inputbox("frameeditorbendsnapsize", dx + dw - capwid - 50, dy + 4, capwid + 50, "", tab.bend.tbx_snap, null))
		tab.bend.snap_size = string_get_real(tab.bend.tbx_snap.text, 0)
}
tab_next()

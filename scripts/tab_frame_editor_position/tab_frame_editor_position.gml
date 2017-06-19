 /// tab_frame_editor_position()

var mul, snapval, capwid;
mul = point3D_distance(tl_edit.pos, cam_work_from) / 100
snapval = tab.position.snap_enabled * tab.position.snap_size
capwid = text_caption_width("frameeditorpositionx", "frameeditorpositiony", "frameeditorpositionz")

axis_edit = X
tab_control_dragger()
draw_dragger("frameeditorpositionx", dx, dy, dw, tl_edit.value[XPOS], mul / tl_edit.value_inherit[XSCA], -no_limit, no_limit, 0, snapval, tab.position.tbx_x, action_tl_frame_pos, capwid)
tab_next()

axis_edit = test(setting_z_is_up, Y, Z)
tab_control_dragger() 
draw_dragger("frameeditorpositiony", dx, dy, dw, tl_edit.value[XPOS + axis_edit], mul / tl_edit.value_inherit[XSCA + axis_edit], -no_limit, no_limit, 0, snapval, tab.position.tbx_y, action_tl_frame_pos, capwid)
tab_next()

axis_edit = test(setting_z_is_up, Z, Y)
tab_control_dragger()
draw_dragger("frameeditorpositionz", dx, dy, dw, tl_edit.value[XPOS + axis_edit], mul / tl_edit.value_inherit[XSCA + axis_edit], -no_limit, no_limit, 0, snapval, tab.position.tbx_z, action_tl_frame_pos, capwid)
tab_next()

// Tools
tab_control(24)
if (draw_button_normal("frameeditorpositionreset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.reset))
	action_tl_frame_pos_xyz(point3D(tl_edit.value_default[XPOS], tl_edit.value_default[YPOS], tl_edit.value_default[ZPOS]))
	
if (draw_button_normal("frameeditorpositioncopy", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.copy))
	tab.position.copy = point3D(tl_edit.value[XPOS], tl_edit.value[YPOS], tl_edit.value[ZPOS])
	
if (draw_button_normal("frameeditorpositionpaste", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.paste))
	action_tl_frame_pos_xyz(tab.position.copy)
	
if (draw_button_normal("frameeditorpositionsnap", dx + 25 * 3, dy, 24, 24, e_button.NO_TEXT, tab.position.snap_enabled, false, true, icons.grid))
	tab.position.snap_enabled=!tab.position.snap_enabled
	
if (tab.position.snap_enabled)
{
	capwid = text_caption_width("frameeditorpositionsnapsize")
	if (draw_inputbox("frameeditorpositionsnapsize", dx + dw - capwid - 50, dy + 4, capwid + 50, "", tab.position.tbx_snap, null))
		tab.position.snap_size = string_get_real(tab.position.tbx_snap.text, 0)
}
tab_next()

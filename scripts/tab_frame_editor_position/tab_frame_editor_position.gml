 /// tab_frame_editor_position()

var mul, snapval, capwid, def;
mul = max(1, point3D_distance(tl_edit.world_pos, cam_work_from)) / 100
snapval = tab.position.snap_enabled * tab.position.snap_size
capwid = text_caption_width("frameeditorpositionx", "frameeditorpositiony", "frameeditorpositionz")

// Parts default to their spawn position, other objects to (0, 0, 0)
if (tl_edit.part_of = null)
	def = point3D(0, 0, 0)
else
	def = point3D(tl_edit.value_default[e_value.POS_X], tl_edit.value_default[e_value.POS_Y], tl_edit.value_default[e_value.POS_Z])
	
axis_edit = X
tab_control_dragger()
draw_dragger("frameeditorpositionx", dx, dy, dw, tl_edit.value[e_value.POS_X], mul / tl_edit.value_inherit[e_value.SCA_X], -no_limit, no_limit, def[X], snapval, tab.position.tbx_x, action_tl_frame_pos, capwid)
tab_next()

axis_edit = setting_z_is_up ? Y : Z
tab_control_dragger() 
draw_dragger("frameeditorpositiony", dx, dy, dw, tl_edit.value[e_value.POS_X + axis_edit], mul / tl_edit.value_inherit[e_value.SCA_X + axis_edit], -no_limit, no_limit, def[X + axis_edit], snapval, tab.position.tbx_y, action_tl_frame_pos, capwid)
tab_next()

axis_edit = setting_z_is_up ? Z : Y
tab_control_dragger()
draw_dragger("frameeditorpositionz", dx, dy, dw, tl_edit.value[e_value.POS_X + axis_edit], mul / tl_edit.value_inherit[e_value.SCA_X + axis_edit], -no_limit, no_limit, def[X + axis_edit], snapval, tab.position.tbx_z, action_tl_frame_pos, capwid)
tab_next()

// Tools
tab_control(24)
if (draw_button_normal("frameeditorpositionreset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.RESET))
	action_tl_frame_pos_xyz(point3D(tl_edit.value_default[e_value.POS_X], tl_edit.value_default[e_value.POS_Y], tl_edit.value_default[e_value.POS_Z]))
	
if (draw_button_normal("frameeditorpositioncopy", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.COPY))
	tab.position.copy = point3D(tl_edit.value[e_value.POS_X], tl_edit.value[e_value.POS_Y], tl_edit.value[e_value.POS_Z])
	
if (draw_button_normal("frameeditorpositionpaste", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.PASTE))
	action_tl_frame_pos_xyz(tab.position.copy)
	
if (draw_button_normal("frameeditorpositionsnap", dx + 25 * 3, dy, 24, 24, e_button.NO_TEXT, tab.position.snap_enabled, false, true, icons.GRID))
	tab.position.snap_enabled = !tab.position.snap_enabled
	
if (tab.position.snap_enabled)
{
	capwid = text_caption_width("frameeditorpositionsnapsize")
	if (draw_inputbox("frameeditorpositionsnapsize", dx + dw - capwid - 50, dy + 4, capwid + 50, "", tab.position.tbx_snap, null))
		tab.position.snap_size = string_get_real(tab.position.tbx_snap.text, 0)
}
tab_next()

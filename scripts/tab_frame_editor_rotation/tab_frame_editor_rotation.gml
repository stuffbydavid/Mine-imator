/// tab_frame_editor_rotation()

var snapval, capwid;
snapval = tab.rotation.snap_enabled * tab.rotation.snap_size

tab_control(100)
axis_edit = X
draw_wheel("frameeditorrotationx", dx + floor(dw * 0.25) - 25, dy + 50, c_yellow, tl_edit.value[XROT], -no_limit, no_limit, 0, snapval, tab.rotation.loops, tab.rotation.tbx_x, action_tl_frame_rot)

axis_edit = test(setting_z_is_up, Y, Z)
draw_wheel("frameeditorrotationy", dx + floor(dw * 0.5), dy + 50, c_blue, tl_edit.value[XROT + axis_edit], -no_limit, no_limit, 0, snapval, tab.rotation.loops, tab.rotation.tbx_y, action_tl_frame_rot)

axis_edit = test(setting_z_is_up, Z, Y)
draw_wheel("frameeditorrotationz", dx + floor(dw * 0.75) + 25, dy + 50, c_red, tl_edit.value[XROT + axis_edit], -no_limit, no_limit, 0, snapval, tab.rotation.loops, tab.rotation.tbx_z, action_tl_frame_rot)
tab_next()

// Loops
if (tab.rotation.loops)
{
	tab_control_dragger()
	 
	axis_edit = X
	draw_dragger("frameeditorrotationloopsx", dx + floor(dw * 0.25) - 25 - 45, dy, 80, floor(tl_edit.value[XROT] / 360), 1 / 10, -no_limit, no_limit, 0, 1, tab.rotation.tbx_loops_x, action_tl_frame_rot_loops, 45)
	
	axis_edit = test(setting_z_is_up, Y, Z)
	draw_dragger("frameeditorrotationloopsy", dx + floor(dw * 0.5) - 25, dy, 80, floor(tl_edit.value[XROT + axis_edit] / 360), 1 / 10, -no_limit, no_limit, 0, 1, tab.rotation.tbx_loops_y, action_tl_frame_rot_loops)
	
	axis_edit = test(setting_z_is_up, Z, Y)
	draw_dragger("frameeditorrotationloopsz", dx + floor(dw * 0.75), dy, 80, floor(tl_edit.value[XROT + axis_edit] / 360), 1 / 10, -no_limit, no_limit, 0, 1, tab.rotation.tbx_loops_z, action_tl_frame_rot_loops)
	tab_next()
	dy += 10
}

// Tools
tab_control(24)

if (draw_button_normal("frameeditorrotationreset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.reset))
	action_tl_frame_rot_xyz(point3D(0, 0, 0))
	
if (draw_button_normal("frameeditorrotationloops", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, tab.rotation.loops, false, true, icons.loops))
	tab.rotation.loops=!tab.rotation.loops
	
if (draw_button_normal("frameeditorrotationcopy", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.copy))
	tab.rotation.copy = point3D(tl_edit.value[XROT], tl_edit.value[YROT], tl_edit.value[ZROT])
	
if (draw_button_normal("frameeditorrotationpaste", dx + 25 * 3, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.paste))
	action_tl_frame_rot_xyz(tab.rotation.copy)
	
if (draw_button_normal("frameeditorrotationsnap", dx + 25 * 4, dy, 24, 24, e_button.NO_TEXT, tab.rotation.snap_enabled, false, true, icons.grid))
	tab.rotation.snap_enabled=!tab.rotation.snap_enabled
	
if (tab.rotation.snap_enabled)
{
	capwid = text_caption_width("frameeditorrotationsnapsize")
	if (draw_inputbox("frameeditorrotationsnapsize", dx + dw - capwid - 50, dy + 4, capwid + 50, "", tab.rotation.tbx_snap, null))
		tab.rotation.snap_size = string_get_real(tab.rotation.tbx_snap.text, 0)
}
tab_next()

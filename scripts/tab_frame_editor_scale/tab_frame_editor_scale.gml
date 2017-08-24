/// tab_frame_editor_scale()

var snapval = max(0.0001, tab.scale.snap_enabled * tab.scale.snap_size);

if (tab.scale.scale_all) // Simple scaling
{
	tab_control_dragger()
	draw_dragger("frameeditorscalexyz", dx, dy, dw, tl_edit.value[e_value.SCA_X], max(0.0001, tl_edit.value[e_value.SCA_X] / 50), snapval, no_limit, 1, snapval, tab.scale.tbx_x, action_tl_frame_scale_all)
	tab_next()
}
else
{
	var capwid = text_caption_width("frameeditorscalex", "frameeditorscaley", "frameeditorscalez");
	
	axis_edit = X
	tab_control_dragger()
	draw_dragger("frameeditorscalex", dx, dy, dw, tl_edit.value[e_value.SCA_X], max(0.0001, tl_edit.value[e_value.SCA_X] / 50), snapval, no_limit, 1, snapval, tab.scale.tbx_x, action_tl_frame_scale, capwid)
	tab_next()
	
	axis_edit = test(setting_z_is_up, Y, Z)
	tab_control_dragger()
	draw_dragger("frameeditorscaley", dx, dy, dw, tl_edit.value[e_value.SCA_X + axis_edit], max(0.0001, tl_edit.value[e_value.SCA_X + axis_edit] / 50), snapval, no_limit, 1, snapval, tab.scale.tbx_y, action_tl_frame_scale, capwid)
	tab_next()
	
	axis_edit = test(setting_z_is_up, Z, Y)
	tab_control_dragger()
	draw_dragger("frameeditorscalez", dx, dy, dw, tl_edit.value[e_value.SCA_X + axis_edit], max(0.0001, tl_edit.value[e_value.SCA_X + axis_edit] / 50), snapval, no_limit, 1, snapval, tab.scale.tbx_z, action_tl_frame_scale, capwid)
	tab_next()
}

// Tools
tab_control(24)

if (draw_button_normal("frameeditorscalereset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.RESET))
	action_tl_frame_scale_xyz(point3D(1, 1, 1))
	
if (draw_button_normal("frameeditorscaleall", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, tab.scale.scale_all, false, true, icons.SCALE_ALL))
	tab.scale.scale_all = !tab.scale.scale_all
	
if (draw_button_normal("frameeditorscalecopy", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.COPY))
	tab.scale.copy = point3D(tl_edit.value[e_value.SCA_X], tl_edit.value[e_value.SCA_Y], tl_edit.value[e_value.SCA_Z])
	
if (draw_button_normal("frameeditorscalepaste", dx + 25 * 3, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.PASTE))
	action_tl_frame_scale_xyz(tab.scale.copy)
	
if (draw_button_normal("frameeditorscalesnap", dx + 25 * 4, dy, 24, 24, e_button.NO_TEXT, tab.scale.snap_enabled, false, true, icons.GRID))
	tab.scale.snap_enabled = !tab.scale.snap_enabled
	
if (tab.scale.snap_enabled)
{
	capwid = text_caption_width("frameeditorscalesnapsize")
	if (draw_inputbox("frameeditorscalesnapsize", dx + dw - capwid - 50, dy + 4, capwid + 50, "", tab.scale.tbx_snap, null))
		tab.scale.snap_size = string_get_real(tab.scale.tbx_snap.text, 0)
}

tab_next()

/// tab_properties_info()

var capwid = text_caption_width("timelineeditorname", "timelineeditortext", "timelineeditortype");

// Name
tab_control_inputbox()
tab.info.tbx_name.text = tl_edit.name
draw_inputbox("timelineeditorname", dx, dy, dw, string_remove_newline(tl_edit.display_name), tab.info.tbx_name, action_tl_name, capwid)
tab_next()

if (tl_edit.type = "text")
{
	// Text
	tab_control(110)
	tab.info.tbx_text.text = tl_edit.text
	draw_inputbox("timelineeditortext", dx, dy, dw, "", tab.info.tbx_text, action_tl_text, capwid, 110)
	tab_next()
}

// Type
tab_control(18)
draw_label(text_get("timelineeditortype") + ":", dx, dy)
draw_label(string_remove_newline(tl_edit.type_name), dx + capwid, dy)
tab_next()

// Rotation point
if (tl_edit.value_type[e_value_type.ROTPOINT])
{
	tab_control_checkbox()
	draw_checkbox("timelineeditorrotpointcustom", dx, dy, tl_edit.rot_point_custom, action_tl_rotpoint_custom)
	tab_next()
	
	if (tl_edit.rot_point_custom)
	{
		var snapval, mul, def;
		snapval = tab.info.rot_point_snap * tab.info.rot_point_snap_size
		mul = point3D_distance(tl_edit.world_pos, cam_from) / 500
		if (tl_edit.temp)
			def = tl_edit.temp.rot_point
		else
			def = point3D(0, 0, 0)
		
		tab.info.rot_point_mouseon = false
		capwid = text_caption_width("timelineeditorrotpointx", "timelineeditorrotpointy", "timelineeditorrotpointz")
		
		axis_edit = X
		tab_control_dragger()
		if (app_mouse_box(dx, dy, dw, 18) && content_mouseon)
			tab.info.rot_point_mouseon = true
		draw_dragger("timelineeditorrotpointx", dx, dy, dw, tl_edit.rot_point[X], mul, -no_limit, no_limit, def[X], snapval, tab.info.tbx_rot_point_x, action_tl_rotpoint, capwid)
		tab_next()
		
		axis_edit = test(setting_z_is_up, Y, Z)
		tab_control_dragger()
		if (app_mouse_box(dx, dy, dw, 18) && content_mouseon)
			tab.info.rot_point_mouseon = true
		draw_dragger("timelineeditorrotpointy", dx, dy, dw, tl_edit.rot_point[axis_edit], mul, -no_limit, no_limit, def[axis_edit], snapval, tab.info.tbx_rot_point_y, action_tl_rotpoint, capwid)
		tab_next()
		
		axis_edit = test(setting_z_is_up, Z, Y)
		tab_control_dragger()
		if (app_mouse_box(dx, dy, dw, 18) && content_mouseon)
			tab.info.rot_point_mouseon = true
		draw_dragger("timelineeditorrotpointz", dx, dy, dw, tl_edit.rot_point[axis_edit], mul, -no_limit, no_limit, def[axis_edit], snapval, tab.info.tbx_rot_point_z, action_tl_rotpoint, capwid)
		tab_next()
		
		// Tools
		tab_control(24)
		
		if (draw_button_normal("timelineeditorrotpointreset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.RESET))
			action_tl_rotpoint_all(def)
			
		if (draw_button_normal("timelineeditorrotpointcopy", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.COPY))
			tab.info.rot_point_copy = tl_edit.rot_point
			
		if (draw_button_normal("timelineeditorrotpointpaste", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.PASTE))
			action_tl_rotpoint_all(tab.info.rot_point_copy)
			
		if (draw_button_normal("timelineeditorrotpointsnap", dx + 25 * 3, dy, 24, 24, e_button.NO_TEXT, tab.info.rot_point_snap, false, true, icons.GRID))
			tab.info.rot_point_snap = !tab.info.rot_point_snap
			
		if (tab.info.rot_point_snap)
		{
			capwid = text_caption_width("timelineeditorrotpointsnapsize")
			if (draw_inputbox("timelineeditorrotpointsnapsize", dx + dw - capwid - 50, dy + 4, capwid + 50, "", tab.info.tbx_rot_point_snap, null, capwid))
				tab.info.rot_point_snap_size = string_get_real(tab.info.tbx_rot_point_snap.text, 0)
		}
		
		tab_next()
	}
}

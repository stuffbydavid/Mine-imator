/// tab_frame_editor_bend()

function tab_frame_editor_bend()
{
	if (tl_edit.model_part = null || tl_edit.model_part.bend_part = null || !tl_edit.value_type[e_value_type.TRANSFORM_BEND])
		return 0
	
	context_menu_group_temp = e_context_group.BEND
	tab_frame_editor_buttons()
	draw_label(text_get("frameeditorbend"), dx, dy + 12, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
	dy += 26
	
	var snapval = (dragger_snap ? setting_snap_size_rotation : 0.1);
	
	// Sliders
	var axis, axislen, axisname, wheelx, wheel, color;
	axislen = 0
	for (var i = X; i <= Z; i++)
		axislen += (tl_edit.model_part.bend_axis[i])
	
	if (!setting_z_is_up)
		axis = array(X, Z, Y)
	else
		axis = array(X, Y, Z)
	axisname = array("x", "y", "z")
	
	if (axislen = 3)
		wheelx = [floor(dx + dw/6), floor(dx + dw/2), floor(dx + dw - dw/6)]
	else if (axislen = 2)
		wheelx = [dx + floor(dw * 0.25), dx + floor(dw * 0.75), 0]
	else
		wheelx = [dx + floor(dw * 0.5), 0, 0]
	wheel = 0
	
	color = [c_control_cyan, setting_z_is_up ? c_axisyellow : c_axismagenta, setting_z_is_up ? c_axismagenta : c_axisyellow]
	
	if (axislen > 0)
	{
		if (tab.transform.bend_sliders)
		{
			for (var i = 0; i < 3; i++)
			{
				axis_edit = axis[i]
				if (!tl_edit.model_part.bend_axis[axis_edit])
					continue
				
				tab_control_meter()
				draw_meter("frameeditorbend" + axisname[i], dx, dy, dw, tl_edit.value[e_value.BEND_ANGLE_X + axis_edit], tl_edit.model_part.bend_direction_min[axis_edit], tl_edit.model_part.bend_direction_max[axis_edit], 0, snapval, tab.transform.tbx_bend[i], action_tl_frame_bend_angle)
				tab_next()
			}
		}
		else
		{
			if (!app.panel_compact)
			{
				tab_control_wheel()
			
				for (var i = 0; i < 3; i++)
				{
					axis_edit = axis[i]
					if (!tl_edit.model_part.bend_axis[axis_edit])
						continue
				
					draw_wheel("frameeditorbendwheel" + axisname[i], wheelx[wheel], dy + 24, color[axis_edit], tl_edit.value[e_value.BEND_ANGLE_X + axis_edit], tl_edit.model_part.bend_direction_min[axis_edit], tl_edit.model_part.bend_direction_max[axis_edit], 0, snapval, tab.transform.tbx_bend[i], action_tl_frame_bend_angle)
					wheel++
				}
			
				tab_next()
			}
			
			for (var i = 0; i < 3; i++)
			{
				axis_edit = axis[i]
				if (!tl_edit.model_part.bend_axis[axis_edit])
					continue
				
				textfield_group_add("frameeditorbend" + axisname[i], tl_edit.value[e_value.BEND_ANGLE_X + axis_edit], 0, action_tl_frame_bend_angle, axis_edit, tab.transform.tbx_bend[axis_edit], null, 0.1, tl_edit.model_part.bend_direction_min[axis_edit], tl_edit.model_part.bend_direction_max[axis_edit])
			}
			
			tab_control_textfield_group(false)
			draw_textfield_group("frameeditorbend", (axislen = 1) ? floor(dx + dw/2 - dragger_width/2) : dx, dy, (axislen = 1) ? dragger_width : dw, 0.1, 0, 0, snapval, false, true, 2)
			tab_next()
		}
	}
	
	context_menu_group_temp = null
}

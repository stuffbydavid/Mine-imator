/// tab_frame_editor_bend()

if (tl_edit.model_part = null || tl_edit.model_part.bend_part = null || !tl_edit.value_type[e_value_type.TRANSFORM_BEND])
	return 0

var snapval = (dragger_snap ? setting_snap_size_rotation : 0.1);

// Sliders
var axis, axislen, axisname;
axislen = 0
for (var i = X; i <= Z; i++)
	axislen += (tl_edit.model_part.bend_axis[i])

if (!setting_z_is_up)
	axis = array(X, Z, Y)
else
	axis = array(X, Y, Z)
axisname = array("x", "y", "z")

context_menu_group_temp = e_context_group.BEND

if (axislen > 0)
{
	for (var i = 0; i < 3; i++)
	{
		axis_edit = axis[i]
		if (!tl_edit.model_part.bend_axis[axis_edit])
			continue
		
		tab_control_meter()
		draw_meter("frameeditorbend" + axisname[i], dx, dy, dw, tl_edit.value[e_value.BEND_ANGLE_X + axis_edit], 48, tl_edit.model_part.bend_direction_min[axis_edit], tl_edit.model_part.bend_direction_max[axis_edit], 0, snapval, tab.transform.tbx_bend[i], action_tl_frame_bend_angle)
		tab_next()
	}
}

context_menu_group_temp = null

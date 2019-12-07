/// tab_frame_editor_bend()

if (tl_edit.model_part = null || tl_edit.model_part.bend_part = null)
	return 0
	
// Wheels
var axis, axislen, axisname;
axislen = 0
for (var i = X; i <= Z; i++)
	axislen += (tl_edit.model_part.bend_axis[i])

if (!setting_z_is_up)
	axis = array(X, Z, Y)
else
	axis = array(X, Y, Z)
axisname = array("x", "y", "z")

// Set the location and size of the wheels
var rad, spr, wheelx;
rad = 50
spr = spr_circle_100
if (axislen = 3)
{
	rad = 40
	spr = spr_circle_80
	wheelx[0] = dw * 0.25 - 25
	wheelx[1] = dw * 0.5
	wheelx[2] = dw * 0.75 + 25
}
else if (axislen = 2)
{
	wheelx[0] = dw * 0.33 - 25
	wheelx[1] = dw * 0.66 + 25
}
else
	wheelx[0] = dw * 0.5

var snapval = tab.bend.snap_enabled * tab.bend.snap_size;
if (axislen > 0)
{
	var n = 0;
	for (var i = 0; i < 3; i++)
	{
		axis_edit = axis[i]
		if (!tl_edit.model_part.bend_axis[axis_edit])
			continue
		
		tab_control_meter()
		draw_meter("frameeditorbend" + axisname[i], dx, dy, dw, tl_edit.value[e_value.BEND_ANGLE_X + axis_edit], 48, tl_edit.model_part.bend_direction_min[axis_edit], tl_edit.model_part.bend_direction_max[axis_edit], 0, snapval, tab.bend.tbx_wheel[i], action_tl_frame_bend_angle)
		tab_next()
		
		n++
	}
	
}

// Tools
tab_control(24)

if (draw_button_normal("frameeditorbendreset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.RESET))
	action_tl_frame_bend_angle_xyz(tl_edit.model_part.bend_default_angle)
	
if (draw_button_normal("frameeditorbendcopy", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.COPY))
	tab.bend.copy = vec3(tl_edit.value[e_value.BEND_ANGLE_X], tl_edit.value[e_value.BEND_ANGLE_Y], tl_edit.value[e_value.BEND_ANGLE_Z])
	
if (draw_button_normal("frameeditorbendpaste", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.PASTE))
	action_tl_frame_bend_angle_xyz(tab.bend.copy)
	
if (draw_button_normal("frameeditorbendsnap", dx + 25 * 3, dy, 24, 24, e_button.NO_TEXT, tab.bend.snap_enabled, false, true, icons.GRID))
	tab.bend.snap_enabled = !tab.bend.snap_enabled
	
if (tab.bend.snap_enabled)
{
	capwid = text_caption_width("frameeditorbendsnapsize")
	if (draw_inputbox("frameeditorbendsnapsize", dx + dw - capwid - 50, dy + 4, capwid + 50, "", tab.bend.tbx_snap, null))
		tab.bend.snap_size = string_get_real(tab.bend.tbx_snap.text, 0)
}
tab_next()

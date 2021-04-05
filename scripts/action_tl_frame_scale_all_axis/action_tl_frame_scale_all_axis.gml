/// action_tl_frame_scale_all_axis(value, add)
/// @arg value
/// @arg add

var val, add;
val = argument0
add = argument1

tl_value_set_start(action_tl_frame_scale_all_axis, true)

var oldval, mul;
oldval = tl_edit.value[e_value.SCA_X + axis_edit]
	
if (string_contains(window_busy, "drag") || string_contains(window_busy, "rendercontrol"))
{
	// Start
	if (!history_data.scale_link_drag)
	{
		history_data.scale_link_drag = true
		history_data.scale_oldval = oldval
		
		history_data.scale_link_drag_val += val
		mul = (oldval + history_data.scale_link_drag_val) / oldval
	}
	else // Dragging
	{
		oldval = history_data.scale_oldval
		
		history_data.scale_link_drag_val += val
		mul = (oldval + history_data.scale_link_drag_val) / oldval
	}
}
else if (history_data.scale_link_drag) // Stop dragging
{
	oldval = history_data.scale_oldval
	
	history_data.scale_link_drag_val += val
	mul = (oldval + history_data.scale_link_drag_val) / oldval
}
else // Manual input
	mul = val / oldval

tl_value_set(e_value.SCA_X, mul, false, true)
tl_value_set(e_value.SCA_Y, mul, false, true)
tl_value_set(e_value.SCA_Z, mul, false, true)

tl_value_set_done()

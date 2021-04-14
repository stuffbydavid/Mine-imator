/// action_tl_frame_scale_all_axis(value, add)
/// @arg value
/// @arg add

var val, add;
val = argument0
add = argument1

var oldval, historyobj, mul, stopdrag;
oldval = tl_edit.value[e_value.SCA_X + axis_edit]
historyobj = (history_amount = 0 ? null : history[0])
stopdrag = false

if (string_contains(window_busy, "drag") || string_contains(window_busy, "rendercontrol"))
{
	// Start
	if (historyobj = null || !historyobj.scale_link_drag)
	{
		tl_value_set_start(action_tl_frame_scale_all_axis, false)
		
		history_data.scale_link_drag = true
		history_data.scale_oldval = oldval
		
		history_data.scale_link_drag_val += val
		mul = (oldval + history_data.scale_link_drag_val) / oldval
	}
	else // Dragging
	{
		tl_value_set_start(action_tl_frame_scale_all_axis, true)
		
		oldval = history_data.scale_oldval
		history_data.scale_link_drag_val += val
		mul = (oldval + history_data.scale_link_drag_val) / oldval
	}
}
else if (historyobj.scale_link_drag) // Stop dragging
{
	tl_value_set_start(action_tl_frame_scale_all_axis, true)
	
	stopdrag = true
	oldval = history_data.scale_oldval
	history_data.scale_link_drag_val += val
	mul = (oldval + history_data.scale_link_drag_val) / oldval
}
else // Manual input
{
	tl_value_set_start(action_tl_frame_scale_all_axis, true)
	
	mul = val / oldval
}

tl_value_set(e_value.SCA_X, mul, false, true)
tl_value_set(e_value.SCA_Y, mul, false, true)
tl_value_set(e_value.SCA_Z, mul, false, true)

tl_value_set_done()

if (stopdrag)
	history_data.scale_link_drag = false

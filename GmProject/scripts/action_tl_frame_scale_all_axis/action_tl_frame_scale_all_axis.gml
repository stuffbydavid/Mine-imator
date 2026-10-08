function action_tl_frame_scale_all_axis(value, add)
{
	var oldval, historyobj, mul, stopdrag;
	axis_edit = X
	oldval = tl_edit.value[e_value.SCA_X + axis_edit]
	historyobj = (history_pos > 0 || history_amount = 0 ? null : history[0])
	stopdrag = false
	
	if (string_contains(window_busy, "drag") || string_contains(window_busy, "render/control"))
	{
		tl_value_set_start(action_tl_frame_scale_all_axis, historyobj != null && historyobj.scale_link_drag)
		
		if (!history_data.scale_link_drag)
		{
			history_data.scale_link_drag = true
			history_data.scale_oldval = oldval
		}
		
		stopdrag = !add
		oldval = history_data.scale_oldval
		history_data.scale_link_drag_val += value
		
		mul = (oldval + history_data.scale_link_drag_val) / oldval
	}
	else // Manual input
	{
		tl_value_set_start(action_tl_frame_scale_all_axis, historyobj = null || !historyobj.scale_link_drag)
		history_data.scale_link_drag = false
		
		mul = value / oldval
	}
	
	tl_value_set(e_value.SCA_X, mul, false, true)
	tl_value_set(e_value.SCA_Y, mul, false, true)
	tl_value_set(e_value.SCA_Z, mul, false, true)
	
	tl_value_set_done()
	
	if (stopdrag)
		history_data.scale_link_drag = false
}

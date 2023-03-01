/// app_update_toasts()

function app_update_toasts()
{
	// Execute actions
	if (toast_script != null)
	{
		if (toast_script_value != null)
			script_execute(toast_script, toast_script_value)
		else
			script_execute(toast_script)
	}
	
	toast_script = null
	toast_script_value = null
	
	// Update alpha
	with (obj_toast)
	{
		if (remove)
		{
			if (app.setting_reduced_motion)
				remove_alpha = 0
			else
				remove_alpha -= (.1 * delta)
		}
			
	}
	
	// Offscreen and ready to remove
	with (obj_toast)
	{
		if (remove && remove_alpha < 0)
			with (app)
				toast_close(other)
	}
	
	toast_amount = ds_list_size(toast_list)
	
	// Calculate y position of toasts(Starting from bottom)
	var toasty = window_height;
	for (var i = toast_amount - 1; i >= 0; i--)
	{
		var toast = toast_list[|i];
		
		if (toast.remove)
			continue
		
		with (toast)
		{
			// Delay to ensure smooth entry animation
			//if (current_time - time_created < 100)
			//	continue
			
			toasty -= (16 + toast_height)
			
			toast_goal_y = toasty
			toast_y += (toast_goal_y - toast_y) / max(1, 2.5 / delta)
		}
	}
}

/// app_update_micro_animations()

function app_update_micro_animations()
{
	var constantspeed, inease, outease;
	constantspeed = 0.095
	inease = "easeoutcirc"
	outease = "easeoutcirc"
	
	// Scrollbars
	with (obj_scrollbar)
	{
		if (app.setting_reduced_motion || !value_ease)
			value = value_goal
		else
			value += floor((value_goal - value) / max(1, 4 / delta))
		
		mousenear.update(constantspeed)
	}
	
	// Timeline zoom
	if (window_state = "")
	{
		if (timeline_zoom != timeline_zoom_goal)
		{
			timeline_zoom += (timeline_zoom_goal - timeline_zoom) / max(1, 4 / delta)
			timeline.hor_scroll.value = max(0, timeline.hor_scroll.value)
		}
	}
	
	with (obj_view)
	{
		if (app.setting_reduced_motion)
			toolbar_alpha = toolbar_alpha_goal
		else
			toolbar_alpha += (toolbar_alpha_goal - toolbar_alpha) / max(1, 5 / delta)
		
		if (toolbar_alpha > .97 && toolbar_alpha_goal = 1)
			toolbar_alpha = 1
	}
	
	// Component animations
	for (var i = 0; i < ds_list_size(microani_list); i++)
	{
		var ani = microani_list[|i];
		
		// Delete after 3 seconds
		if (ani.steps_hidden > 60 * 3)
			ds_list_add(microani_delete_list, ani)
		
		ani.steps_alive++
		ani.steps_hidden++
		
		ani.update(constantspeed * 1.5)
	}
	
	for (var i = 0; i < ds_list_size(microani_delete_list); i++)
	{
		var ani = microani_delete_list[|i];
		
		ds_list_delete_value(microani_list, ani)
		ds_map_delete(microanis, ani.key)
		
		delete ani
	}
	ds_list_clear(microani_delete_list)
}

function app_update_micro_animations()
{
	var constantspeed = 0.1;
	
	// Work camera angle
	if (window_state = "")
	{
		if (cam_work_angle_xy != cam_work_angle_goal_xy)
			cam_work_angle_xy += (cam_work_angle_goal_xy - cam_work_angle_xy) / max(1, 4 / delta)
		if (abs(cam_work_angle_goal_xy - cam_work_angle_xy) < 0.0001)
			cam_work_angle_xy = cam_work_angle_goal_xy
		
		if (cam_work_angle_z != cam_work_angle_goal_z)
			cam_work_angle_z += (cam_work_angle_goal_z - cam_work_angle_z) / max(1, 4 / delta)
		if (abs(cam_work_angle_goal_z - cam_work_angle_z) < 0.0001)
			cam_work_angle_z = cam_work_angle_goal_z
		
		if (cam_work_angle_look_xy != cam_work_angle_goal_look_xy)
			cam_work_angle_look_xy += (cam_work_angle_goal_look_xy - cam_work_angle_look_xy) / max(1, 4 / delta)
		if (abs(cam_work_angle_goal_look_xy - cam_work_angle_look_xy) < 0.0001)
			cam_work_angle_look_xy = cam_work_angle_goal_look_xy
		
		if (cam_work_angle_look_z != cam_work_angle_goal_look_z)
			cam_work_angle_look_z += (cam_work_angle_goal_look_z - cam_work_angle_look_z) / max(1, 4 / delta)
		if (abs(cam_work_angle_goal_look_z - cam_work_angle_look_z) < 0.0001)
			cam_work_angle_look_z = cam_work_angle_goal_look_z
	}
	
	// Timeline zoom
	if (window_state = "")
	{
		if (timeline_zoom != timeline_zoom_goal)
		{
			timeline_zoom += (timeline_zoom_goal - timeline_zoom) / max(1, 4 / delta)
			timeline.hor_scroll.value_goal = max(0, timeline.hor_scroll.value_goal)
			timeline.hor_scroll.value = max(0, timeline.hor_scroll.value)
		}
		
		if (abs(timeline_zoom_goal - timeline_zoom) < 0.0001)
			timeline_zoom = timeline_zoom_goal
	}
	
	// Scrollbars
	with (obj_scrollbar)
	{
		if (!value_ease)
			value = value_goal
		else
			value += (value_goal - value) / max(1, 4 / delta)
		
		mousenear.update(constantspeed)
	}
	
	with (obj_view)
	{
		if (app.setting_reduced_motion)
		{
			toolbar_alpha = toolbar_alpha_goal
			toolbar_nav_alpha = toolbar_nav_alpha_goal
		}
		else
		{
			toolbar_alpha += (toolbar_alpha_goal - toolbar_alpha) / max(1, 4 / delta)
			toolbar_nav_alpha += (toolbar_nav_alpha_goal - toolbar_nav_alpha) / max(1, 4 / delta)
		}
		
		if (toolbar_alpha > .97 && toolbar_alpha_goal = 1)
			toolbar_alpha = 1
		if (toolbar_nav_alpha > .97 && toolbar_nav_alpha_goal = 1)
			toolbar_nav_alpha = 1
	}
	
	// Component animations
	for (var i = 0; i < ds_list_size(microani_list); i++)
	{
		var ani = microani_list[|i];
		
		// Delete after 3 seconds
		if (ani.steps_hidden > 60 * 3)
		{
			ds_list_add(microani_delete_list, ani)
			continue
		}
		
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

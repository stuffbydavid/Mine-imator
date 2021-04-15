/// app_update_micro_animations()

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
	
	if (mousenear != mousenear_prev)
	{
		mousenear_base = mousenear_ani
		mousenear_prev = mousenear
		mousenear_offset_ani = 0.0
			
		if (!mousenear)
			mousenear_offset = -mousenear_base
		else
			mousenear_offset = 1.0 - mousenear_base
	}
		
	mousenear_offset_ani += (constantspeed * 1) * delta
	mousenear_offset_ani_ease = ease((mousenear ? outease : inease), mousenear_offset_ani)
	mousenear_offset_ani = clamp(mousenear_offset_ani, 0, 1)
		
	mousenear_ani = mousenear_base + (mousenear_offset * mousenear_offset_ani)
	mousenear_ani = clamp(mousenear_ani, 0, 1)
		
	mousenear_ani_ease = mousenear_base + (mousenear_offset * mousenear_offset_ani_ease)
	mousenear_ani_ease = clamp(mousenear_ani_ease, 0, 1)
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

// Scrollbar margin offset
with (obj_tab)
{
	if (app.setting_reduced_motion)
		scrollbar_margin = scrollbar_margin_goal
	else
		scrollbar_margin += (scrollbar_margin_goal - scrollbar_margin) / max(1, 5 / delta)
}

// Component animations
with (obj_micro_animation)
{	
	// Delete after 3 seconds
	if (steps_hidden > 60 * 3)
	{
		ds_map_delete(microanis, key)
		instance_destroy()
	}
	
	#region Hover
	
	if (app.setting_reduced_motion)
	{
		hover_ani = hover
		hover_ani_ease = hover
		
		hover_base = hover_ani
		hover_prev = hover
		
		hover_offset = 0.0
		hover_offset_ani = 0.0
	}
	else
	{
		if (hover != hover_prev || steps_alive = 0)
		{
			hover_base = hover_ani
			hover_prev = hover
			hover_offset_ani = 0.0
			
			if (!hover)
				hover_offset = -hover_base
			else
				hover_offset = 1.0 - hover_base
		}
		
		hover_offset_ani += (constantspeed * spd) * delta
		hover_offset_ani_ease = ease((hover ? outease : inease), hover_offset_ani)
		hover_offset_ani = clamp(hover_offset_ani, 0, 1)
		
		hover_ani = hover_base + (hover_offset * hover_offset_ani)
		hover_ani = clamp(hover_ani, 0, 1)
		
		hover_ani_ease = hover_base + (hover_offset * hover_offset_ani_ease)
		hover_ani_ease = clamp(hover_ani_ease, 0, 1)
	}
	
	#endregion
	
	#region Value
	if (app.setting_reduced_motion)
	{
		value_ani = value
		value_ani_ease = value
		
		value_base = value_ani
		value_prev = value
		
		value_offset = 0.0
		value_offset_ani = 0.0
	}
	else
	{
		if (value != value_prev || steps_alive = 0)
		{
			value_base = value_ani
			value_prev = value
			value_offset_ani = 0.0
			
			if (!value)
				value_offset = -value_base
			else
				value_offset = 1.0 - value_base
		}
		
		value_offset_ani += (constantspeed * spd) * delta
		value_offset_ani_ease = ease((value ? outease : inease), value_offset_ani)
		value_offset_ani = clamp(value_offset_ani, 0, 1)
		
		value_ani = value_base + (value_offset * value_offset_ani)
		value_ani = clamp(value_ani, 0, 1)
		
		value_ani_ease = value_base + (value_offset * value_offset_ani_ease)
		value_ani_ease = clamp(value_ani_ease, 0, 1)
	}
	
	#endregion
	
	#region Holding
	
	if (app.setting_reduced_motion)
	{
		holding_ani = holding
		holding_ani_ease = holding
		
		holding_base = holding_ani
		holding_prev = holding
		
		holding_offset = 0.0
		holding_offset_ani = 0.0
	}
	else
	{
		if (holding != holding_prev || steps_alive = 0)
		{
			holding_base = holding_ani
			holding_prev = holding
			holding_offset_ani = 0.0
			
			if (!holding)
				holding_offset = -holding_base
			else
				holding_offset = 1.0 - holding_base
		}
		
		holding_offset_ani += (constantspeed * spd) * delta
		holding_offset_ani_ease = ease((holding ? outease : inease), holding_offset_ani)
		holding_offset_ani = clamp(holding_offset_ani, 0, 1)
		
		holding_ani = holding_base + (holding_offset * holding_offset_ani)
		holding_ani = clamp(holding_ani, 0, 1)
		
		holding_ani_ease = holding_base + (holding_offset * holding_offset_ani_ease)
		holding_ani_ease = clamp(holding_ani_ease, 0, 1)
	}
	
	#endregion
	
	#region Disabled
	
	if (app.setting_reduced_motion)
	{
		disabled_ani = disabled
		disabled_ani_ease = disabled
		
		disabled_base = disabled_ani
		disabled_prev = disabled
		
		disabled_offset = 0.0
		disabled_offset_ani = 0.0
	}
	else
	{
		if (disabled != disabled_prev || steps_alive = 0)
		{
			disabled_base = disabled_ani
			disabled_prev = disabled
			disabled_offset_ani = 0.0
			
			if (!disabled)
				disabled_offset = -disabled_base
			else
				disabled_offset = 1.0 - disabled_base
		}
		
		disabled_offset_ani += (constantspeed * spd) * delta
		disabled_offset_ani_ease = ease((disabled ? outease : inease), disabled_offset_ani)
		disabled_offset_ani = clamp(disabled_offset_ani, 0, 1)
		
		disabled_ani = disabled_base + (disabled_offset * disabled_offset_ani)
		disabled_ani = clamp(disabled_ani, 0, 1)
		
		disabled_ani_ease = disabled_base + (disabled_offset * disabled_offset_ani_ease)
		disabled_ani_ease = clamp(disabled_ani_ease, 0, 1)
	}
	
	#endregion
	
	#region Custom
	
	if (custom_ease)
	{
		if (app.setting_reduced_motion)
		{
			custom_ani = custom
			custom_ani_ease = custom
		
			custom_base = custom_ani
			custom_prev = custom
		
			custom_offset = 0.0
			custom_offset_ani = 0.0
		}
		else
		{
			if (custom != custom_prev || steps_alive = 0)
			{
				custom_base = custom_ani
				custom_prev = custom
				custom_offset_ani = 0.0
			
				if (!custom)
					custom_offset = -custom_base
				else
					custom_offset = 1.0 - custom_base
			}
		
			custom_offset_ani += (constantspeed * spd) * delta
			custom_offset_ani_ease = ease((custom ? outease : inease), custom_offset_ani)
			custom_offset_ani = clamp(custom_offset_ani, 0, 1)
		
			custom_ani = custom_base + (custom_offset * custom_offset_ani)
			custom_ani = clamp(custom_ani, 0, 1)
		
			custom_ani_ease = custom_base + (custom_offset * custom_offset_ani_ease)
			custom_ani_ease = clamp(custom_ani_ease, 0, 1)
		}
	}
	
	#endregion
	
	#region Goal value
	
	if (custom_goal_ease && (goal_ease != goal_value))
	{
		if (app.setting_reduced_motion)
			goal_ease = goal_value
		else
		{
			var valadd = (goal_value - goal_ease) / max(1, 3 / delta);
			goal_ease += valadd
			
			if (abs(valadd) < 0.01)
				goal_ease = goal_value
			
			goal_ease = clamp(goal_ease, 0, 1)
		}
	}
	
	#endregion
	
	steps_alive++
	steps_hidden++
}

/// app_startup_micro_animations()
/// @desc Sets up micro animations for use with components

function app_startup_micro_animations()
{
	globalvar microani_arr, current_microani, microani_list, microani_delete_list;
	globalvar microanis, microani_hover, microani_click, microani_value, microani_prefix;
	
	microani_arr = array(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	current_microani = null
	
	microani_list = ds_list_create()
	microani_delete_list = ds_list_create()
	
	microanis = ds_map_create()
	microani_prefix = ""
	
	enum e_microani
	{
		HOVER,
		RADIO_HOVER,
		PRESS,
		ACTIVE,
		DISABLED,
		CUSTOM,
		HOVER_LINEAR,
		RADIO_HOVER_LINEAR,
		PRESS_LINEAR,
		ACTIVE_LINEAR,
		DISABLED_LINEAR,
		CUSTOM_LINEAR,
		GOAL_EASE
	}
}

function micro_animation(name) constructor
{
	ds_list_add(microani_list, self)
	ds_map_add(microanis, name, self)
	
	key = name
	steps_alive = 0
	steps_hidden = 0
	steps_idle = 0
	
	active = new value_animation()
	hover = new value_animation()
	holding = new value_animation()
	disable = new value_animation()
	custom = new value_animation()
	
	goal_value = 0
	goal_ease = 0
	
	static update = function(spd)
	{
		if (hover.value_ani_linear != hover.value ||
			active.value_ani_linear != active.value ||
			holding.value_ani_linear != holding.value ||
			disable.value_ani_linear != disable.value ||
			custom.value_ani_linear != custom.value)
		{
			active.update(spd)
			hover.update(spd)
			holding.update(spd)
			disable.update(spd)
			custom.update(spd)
		}
		
		if (goal_ease != goal_value)
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
	}
}

function value_animation() constructor
{
	self.init(0)
	
	static init = function(val)
	{
		value = val
		value_prev = val
		value_ani_linear = val
		value_ani_ease = val
		
		value_base = val
		value_offset = val
		value_ani_offset = val
		value_ani_offset_ease = val
	}
	
	static update = function(spd)
	{
		// Don't update
		if (value_ani_linear = value)
			return 0
		
		if (app.setting_reduced_motion)
		{
			value_ani_linear = value
			value_ani_ease = value
			
			value_base = value_ani_linear
			value_prev = value
			
			value_offset = 0.0
			value_ani_offset = 0.0
		}
		else
		{
			if (value != value_prev)
			{
				value_base = value_ani_linear
				value_prev = value
				value_ani_offset = 0.0
				
				if (!value)
					value_offset = -value_base
				else
					value_offset = 1.0 - value_base
			}
			
			value_ani_offset += spd * delta
			value_ani_offset_ease = ease("easeoutcirc", value_ani_offset)
			value_ani_offset = clamp(value_ani_offset, 0, 1)
			
			value_ani_linear = value_base + (value_offset * value_ani_offset)
			value_ani_linear = clamp(value_ani_linear, 0, 1)
			
			value_ani_ease = value_base + (value_offset * value_ani_offset_ease)
			value_ani_ease = clamp(value_ani_ease, 0, 1)
		}
	}
}
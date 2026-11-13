function micro_animation(name) constructor
{
	ds_list_add(microani_list, self)
	ds_map_add(microanis, name, self)
	
	key = name
	steps_alive = 0
	steps_hidden = 0
	
	active = new value_animation()
	hover = new value_animation()
	holding = new value_animation()
	disable = new value_animation()
	custom = new value_animation()
	fade = new value_animation()
	fade.init(1)
	
	goal_value = 0
	goal_ease = 0
	
	static update = function(spd)
	{
		if (hover.value_ani_linear != hover.value ||
			active.value_ani_linear != active.value ||
			holding.value_ani_linear != holding.value ||
			disable.value_ani_linear != disable.value ||
			custom.value_ani_linear != custom.value ||
			fade.value_ani_linear != fade.value)
		{
			active.update(spd)
			hover.update(spd)
			holding.update(spd)
			disable.update(spd)
			custom.update(spd)
			fade.update(spd)
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

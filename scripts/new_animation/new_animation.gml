/// new_animation(name, [value, hover, focus, disabled, [custom, [goal]]])
/// @arg name
/// @arg [value
/// @arg hover
/// @arg focus
/// @arg disabled
/// @arg [custom
/// @arg [goal]]]

function new_animation()
{
	var microanimation = new_obj(obj_micro_animation)
	ds_map_add(microanis, microani_prefix + argument[0], microanimation)
	
	if (argument_count > 1)
	{
		with (microanimation)
		{
			key = microani_prefix + argument[0]
			
			value = argument[1]
			value_ani = value
			value_ani_ease = value
			
			hover = argument[2]
			hover_ani = hover
			hover_ani_ease = hover
			
			holding = argument[3]
			holding_ani = holding
			holding_ani_ease = holding
			
			disabled = argument[4]
			disabled_ani = disabled
			disabled_ani_ease = disabled
			
			if (argument_count > 5)
			{
				custom_ease = true
				
				custom = argument[5]
				custom_ani = disabled
				custom_ani_ease = disabled
			}
			
			if (argument_count > 6)
			{
				custom_goal_ease = true
				
				goal_value = argument[6]
				goal_ease = goal_value
			}
		}
	}
	
	microanimation.spd = 1.5
	
	return microanimation
}

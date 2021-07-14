/// microani_set(name, script, hover, click, active, [disabled, [speed, [custom, [goalval]]]])
/// @arg name
/// @arg script
/// @arg hover
/// @arg click
/// @arg active
/// @arg [disabled
/// @arg [speed
/// @arg [custom
/// @arg [goalval]]]]
/// @desc Sets the global micro animation

function microani_set()
{
	var name, script, hover, click, active, disabled, spd, custom, goalval;
	name = argument[0]
	script = string(argument[1])
	hover = argument[2]
	click = argument[3]
	active = argument[4]
	disabled = false
	spd = 1.5
	custom = false
	goalval = 0
	
	if (argument_count > 5)
		disabled = argument[5]
	
	if (argument_count > 6)
		spd = argument[6]
	
	if (argument_count > 7)
		custom = argument[7]
	
	if (argument_count > 8)
		goalval = argument[8]
	
	var aniname, animation;
	aniname = microani_prefix + (name + script)
	animation = microanis[?aniname]
	
	// Create micro animation object if it doesn't already exist
	if (animation = undefined)
	{
		animation = new micro_animation(aniname)
		animation.active.init(active)
		animation.hover.init(hover)
		animation.holding.init(click)
		animation.disable.init(disabled)
		animation.custom.init(custom)
		
		animation.goal_value = goalval
		animation.goal_ease = goalval
	}
		
	current_microani = animation
	current_microani.steps_hidden = 0
		
	microani_arr[e_microani.HOVER_LINEAR] = current_microani.hover.value_ani_linear
	microani_arr[e_microani.PRESS_LINEAR] = current_microani.holding.value_ani_linear
	microani_arr[e_microani.ACTIVE_LINEAR] = current_microani.active.value_ani_linear
	microani_arr[e_microani.DISABLED_LINEAR] = current_microani.disable.value_ani_linear
	microani_arr[e_microani.CUSTOM_LINEAR] = current_microani.custom.value_ani_linear
		
	microani_arr[e_microani.HOVER] = current_microani.hover.value_ani_ease
	microani_arr[e_microani.PRESS] = current_microani.holding.value_ani_ease
	microani_arr[e_microani.ACTIVE] = current_microani.active.value_ani_ease
	microani_arr[e_microani.DISABLED] = current_microani.disable.value_ani_ease
	microani_arr[e_microani.CUSTOM] = current_microani.custom.value_ani_ease
		
	microani_arr[e_microani.GOAL_EASE] = current_microani.goal_ease
}

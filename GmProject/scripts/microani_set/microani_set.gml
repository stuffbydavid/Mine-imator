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

function microani_set(name, script, hover, click, active, disabled = false, spd = 1.5, custom = false, goalval = 0)
{
	var aniname, animation;
	aniname = microani_prefix + name + string(script)
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
		animation.fade.init(1)
		
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
	microani_arr[e_microani.FADE_LINEAR] = current_microani.fade.value_ani_linear
		
	microani_arr[e_microani.HOVER] = current_microani.hover.value_ani_ease
	microani_arr[e_microani.PRESS] = current_microani.holding.value_ani_ease
	microani_arr[e_microani.ACTIVE] = current_microani.active.value_ani_ease
	microani_arr[e_microani.DISABLED] = current_microani.disable.value_ani_ease
	microani_arr[e_microani.CUSTOM] = current_microani.custom.value_ani_ease
	microani_arr[e_microani.FADE] = current_microani.fade.value_ani_ease
		
	microani_arr[e_microani.GOAL_EASE] = current_microani.goal_ease
}

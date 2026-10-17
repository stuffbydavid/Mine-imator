/// @desc Updates the current micro animation.
/// @arg hover
/// @arg click
/// @arg active
/// @arg [disable]
/// @arg [custom]
/// @arg [goalvalue]

function microani_update(hover, click, active, disable = false, custom = false, goalvalue = 0)
{
	if (current_microani = null)
		return 0
	
	current_microani.hover.value = hover
	current_microani.holding.value = click
	current_microani.active.value = active
	current_microani.disable.value = disable
	current_microani.custom.value = custom
	current_microani.goal_value = goalvalue
}

/// microani_update(hover, click, active, [disabled, [custom, [goal]]])
/// @arg hover
/// @arg click
/// @arg active
/// @arg [disabled
/// @arg [custom
/// @arg [goal]]]
/// @desc Updates the current micro animation

function microani_update()
{
	if (current_microani != null)
	{
		current_microani.hover.value = argument[0]
		current_microani.holding.value = argument[1]
		current_microani.active.value = argument[2]
		
		if (argument_count > 3)
			current_microani.disable.value = argument[3]
		
		if (argument_count > 4)
			current_microani.custom.value = argument[4]
			
		if (argument_count > 5)
			current_microani.goal_value = argument[5]
	}
}

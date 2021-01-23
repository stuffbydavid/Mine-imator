/// microani_update(hover, click, active, [disabled, [custom, [goal]]])
/// @arg hover
/// @arg click
/// @arg active
/// @arg [disabled
/// @arg [custom
/// @arg [goal]]]
/// @desc Updates the current micro animation

if (current_mcroani != null)
{
	current_mcroani.hover = argument[0]
	current_mcroani.holding = argument[1]
	current_mcroani.value = argument[2]
	
	if (argument_count > 3)
		current_mcroani.disabled = argument[3]
	
	if (argument_count > 4)
		current_mcroani.custom = argument[4]
		
	if (argument_count > 5)
		current_mcroani.goal_value = argument[5]
}

/// action_background_sunlight_strength(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.old_value * 100
else if (history_redo)
	val = history_data.new_value * 100
else
{
	val = argument0
	add = argument1
	
	history_set_var(action_background_sunlight_strength, background_sunlight_strength, background_sunlight_strength * add + val / 100, true)
}

background_sunlight_strength = background_sunlight_strength * add + val / 100

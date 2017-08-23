/// action_background_fog_height(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.old_value
else if (history_redo)
	val = history_data.new_value
else
{
	val = argument0
	add = argument1
	if (action_tl_select_single("background"))
	{
		tl_value_set_start(action_background_fog_height, true)
		tl_value_set(BGFOGHEIGHT, val, add)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_fog_height, background_fog_height, background_fog_height * add + val, true)
}

background_fog_height = background_fog_height * add + val

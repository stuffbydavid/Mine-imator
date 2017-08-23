/// action_background_texture_animation_speed(value, add)
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
		tl_value_set_start(action_background_texture_animation_speed, true)
		tl_value_set(BGTEXTUREANISPEED, val, add)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_texture_animation_speed, background_texture_animation_speed, background_texture_animation_speed * add + val, true)
}

background_texture_animation_speed = background_texture_animation_speed * add + val

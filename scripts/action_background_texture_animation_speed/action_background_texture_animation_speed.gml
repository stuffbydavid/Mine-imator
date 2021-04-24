/// action_background_texture_animation_speed(value, add)
/// @arg value
/// @arg add

function action_background_texture_animation_speed(val, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_texture_animation_speed, true)
			tl_value_set(e_value.BG_TEXTURE_ANI_SPEED, val, add)
			tl_value_set_done()
			return 0
		}
		history_set_var(action_background_texture_animation_speed, background_texture_animation_speed, background_texture_animation_speed * add + val, true)
	}
	
	background_texture_animation_speed = background_texture_animation_speed * add + val
}

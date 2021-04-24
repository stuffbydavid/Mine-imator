/// action_background_fog_height(value, add)
/// @arg value
/// @arg add

function action_background_fog_height(val, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_fog_height, true)
			tl_value_set(e_value.BG_FOG_HEIGHT, val, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_fog_height, background_fog_height, background_fog_height * add + val, true)
	}
	
	background_fog_height = background_fog_height * add + val
}

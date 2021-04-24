/// action_background_volumetric_fog_height_fade(value, add)
/// @arg value
/// @arg add

function action_background_volumetric_fog_height_fade(val, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_volumetric_fog_height_fade, true)
			tl_value_set(e_value.BG_VOLUMETRIC_FOG_HEIGHT_FADE, val, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_volumetric_fog_height_fade, background_volumetric_fog_height_fade, background_volumetric_fog_height_fade * add + val, true)
	}
	
	background_volumetric_fog_height_fade = background_volumetric_fog_height_fade * add + val
}

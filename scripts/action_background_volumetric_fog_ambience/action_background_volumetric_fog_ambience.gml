/// action_background_volumetric_fog_ambience(show)
/// @arg show

function action_background_volumetric_fog_ambience(show)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_volumetric_fog_ambience, true)
			tl_value_set(e_value.BG_VOLUMETRIC_FOG_AMBIENCE, show, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_volumetric_fog_ambience, background_volumetric_fog_ambience, show, false)
	}
	
	background_volumetric_fog_ambience = show
}

/// action_background_volumetric_fog_wind(value, add)
/// @arg value
/// @arg add
function action_background_volumetric_fog_wind(val, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_volumetric_fog_wind, true)
			tl_value_set(e_value.BG_VOLUMETRIC_FOG_WIND, val / 100, add)
			tl_value_set_done()
			return 0
		}
		history_set_var(action_background_volumetric_fog_wind, background_volumetric_fog_wind, background_volumetric_fog_wind * add + val / 100, true)
	}
	else
		val *= 100
	
	background_volumetric_fog_wind = background_volumetric_fog_wind * add + val / 100
}

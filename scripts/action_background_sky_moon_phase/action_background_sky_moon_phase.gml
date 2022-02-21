/// action_background_sky_moon_phase(phase)
/// @arg phase

function action_background_sky_moon_phase(phase)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sky_moon_phase, false)
			tl_value_set(e_value.BG_SKY_MOON_PHASE, phase, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sky_moon_phase, background_sky_moon_phase, phase, true)
	}
	
	background_sky_moon_phase = phase
}

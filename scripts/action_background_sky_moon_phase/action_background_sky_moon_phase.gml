/// action_background_sky_moon_phase(phase)
/// @arg phase

var phase;

if (history_undo)
	phase = history_data.old_value
else if (history_redo)
	phase = history_data.new_value
else
{
	phase = argument0
	if (action_tl_select_single("background"))
	{
		tl_value_set_start(action_background_sky_moon_phase, false)
		tl_value_set(e_value.BG_SKY_MOON_PHASE, phase, false)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_sky_moon_phase, background_sky_moon_phase, phase, true)
}

background_sky_moon_phase = phase

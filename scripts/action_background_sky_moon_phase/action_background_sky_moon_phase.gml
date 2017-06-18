/// action_background_sky_moon_phase(phase)
/// @arg phase

var phase;

if (history_undo)
	phase = history_data.oldval
else if (history_redo)
	phase = history_data.newval
else
{
	phase = argument0
	if (action_tl_select_single("background"))
	{
		tl_value_set_start(action_background_sky_moon_phase, false)
		tl_value_set(BGSKYMOONPHASE, phase, false)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_sky_moon_phase, background_sky_moon_phase, phase, true)
}

background_sky_moon_phase = phase

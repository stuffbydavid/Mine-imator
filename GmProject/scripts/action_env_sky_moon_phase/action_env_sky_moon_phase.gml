function action_env_sky_moon_phase(phase)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.ENVIRONMENT))
		{
			tl_value_set_start(action_env_sky_moon_phase, false)
			tl_value_set(e_value.ENV_SKY_MOON_PHASE, phase, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_env_sky_moon_phase, env_sky_moon_phase, phase, true)
	}
	
	env_sky_moon_phase = phase
}

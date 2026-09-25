/// action_tl_play_repeat([seamless])
/// @arg [seamless]

function action_tl_play_repeat(seamless = false)
{
	project_changed = true
	
	if (timeline_seamless_repeat && !setting_advanced_mode) // Turn off seamless loop if its active in simple mode
	{
		timeline_repeat = false
		timeline_seamless_repeat = false
	}
	else if (seamless)
	{
		timeline_seamless_repeat = !timeline_seamless_repeat
		timeline_repeat = false
	}
	else
	{
		timeline_repeat = !timeline_repeat
		timeline_seamless_repeat = false
	}
	
	if (timeline_playing && timeline_length > 0)
	{
		timeline_playing_start_time = current_time
		if (timeline_marker > timeline_length)
			timeline_playing_start_marker = 0
		else
			timeline_playing_start_marker = timeline_marker
	}
}

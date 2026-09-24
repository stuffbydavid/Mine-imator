/// action_tl_play_repeat(seamless)
/// @arg seamless

function action_tl_play_repeat(seamless)
{
	project_changed = true
	
	if (seamless)
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

/// action_tl_play_stop()

function action_tl_play_stop()
{
	if (timeline_playing)
	{
		timeline_marker = timeline_playing_last_marker
		timeline.hor_scroll.value_goal = timeline_playing_start_hor_scroll
		action_tl_play_break()
	}
	else
		timeline_marker = 0
}

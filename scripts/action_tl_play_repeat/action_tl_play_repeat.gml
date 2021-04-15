/// action_tl_play_repeat()

project_changed = true

// Cycle 1
if (!timeline_repeat && !timeline_seamless_repeat)
{
	timeline_repeat = true
}
else if (timeline_repeat) // Cycle 2
{
	timeline_seamless_repeat = true
	timeline_repeat = false
}
else // Cycle 3
{
	timeline_seamless_repeat = false
	timeline_repeat = false
}

if (timeline_playing && timeline_length > 0)
{
	timeline_playing_start_time = current_time
	if (timeline_marker > timeline_length)
		timeline_playing_start_marker = 0
	else
		timeline_playing_start_marker = timeline_marker
}

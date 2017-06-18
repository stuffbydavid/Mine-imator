/// action_toolbar_play_repeat()

project_changed = true
timeline_repeat=!timeline_repeat

if (timeline_playing && timeline_length > 0)
{
	timeline_playing_start_time = current_time
	if (timeline_marker > timeline_length)
		timeline_playing_start_marker = 0
	else
		timeline_playing_start_marker = timeline_marker
}

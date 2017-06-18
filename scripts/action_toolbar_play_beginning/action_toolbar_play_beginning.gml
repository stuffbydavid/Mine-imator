/// action_toolbar_play_beginning()

timeline_playing = true
timeline_playing_start_time = current_time
if (timeline_region_start != null)
{
	timeline_playing_start_marker = timeline_region_start
	timeline_marker = timeline_region_start
}
else
{
	timeline_playing_start_marker = 0
	timeline_marker = 0
}
timeline_marker_previous = timeline_marker + 1
action_toolbar_play_start()

/// action_tl_right()

function action_tl_right()
{
	timeline_marker_move += project_tempo / room_speed
	
	if (setting_timeline_frame_snap)
		timeline_marker = round(timeline_marker_move)
	else
		timeline_marker = timeline_marker_move
	
	if (timeline_repeat || timeline_seamless_repeat)
	{
		if (timeline_region_end != null)
		{
			if (timeline_marker >= timeline_region_end)
				timeline_marker = timeline_region_start
		}
		else if (timeline_marker >= timeline_length && timeline_length > 0)
			timeline_marker = 0
	}
}

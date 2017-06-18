/// action_tl_right()

timeline_marker += project_tempo / room_speed

if (timeline_repeat)
{
    if (timeline_region_end != null)
	{
        if (timeline_marker >= timeline_region_end)
            timeline_marker = timeline_region_start
    }
	else if (timeline_marker >= timeline_length && timeline_length > 0)
        timeline_marker = 0
}

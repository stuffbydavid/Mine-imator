/// action_tl_left()

timeline_marker -= project_tempo / room_speed

if (timeline_repeat)
{
    if (timeline_region_end != null)
	{
        if (timeline_marker < timeline_region_start)
            timeline_marker = timeline_region_end
    }
	else if (timeline_marker < 0)
        timeline_marker = timeline_length
}

timeline_marker = max(0, timeline_marker)

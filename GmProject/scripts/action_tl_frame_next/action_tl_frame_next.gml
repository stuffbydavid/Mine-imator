/// action_tl_frame_next()

function action_tl_frame_next()
{
	timeline_marker = ((ceil(timeline_marker) != timeline_marker) ? ceil(timeline_marker) : timeline_marker + 1)
}

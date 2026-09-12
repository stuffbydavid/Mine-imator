/// action_tl_frame_previous()

function action_tl_frame_previous()
{
	timeline_marker = max(((floor(timeline_marker) != timeline_marker) ? floor(timeline_marker) : timeline_marker - 1), 0)
}

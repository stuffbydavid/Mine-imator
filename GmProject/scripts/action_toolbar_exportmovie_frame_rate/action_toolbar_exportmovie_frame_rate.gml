/// action_toolbar_exportmovie_frame_rate(value)
/// @arg value

function action_toolbar_exportmovie_frame_rate(value)
{
	popup.frame_rate = value
	if (popup.frame_rate > 0)
		popup.framespersecond = popup.frame_rate
}

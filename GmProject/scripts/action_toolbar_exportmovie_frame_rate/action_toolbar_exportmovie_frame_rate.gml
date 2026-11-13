function action_toolbar_exportmovie_frame_rate(value)
{
	popup_current.frame_rate = value
	if (popup_current.frame_rate > 0)
		popup_current.framespersecond = popup_current.frame_rate
}

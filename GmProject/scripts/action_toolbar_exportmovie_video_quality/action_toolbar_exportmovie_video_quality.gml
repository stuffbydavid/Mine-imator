/// action_toolbar_exportmovie_video_quality(videoquality)
/// @arg videoquality

function action_toolbar_exportmovie_video_quality(videoquality)
{
	popup.video_quality = videoquality
	if (popup.video_quality > 0)
		popup.bit_rate = popup.video_quality.bit_rate
}

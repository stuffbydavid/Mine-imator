/// action_toolbar_exportmovie_video_quality(videoquality)
/// @arg videoquality

popup.video_quality = argument0
if (popup.video_quality > 0)
	popup.bit_rate = popup.video_quality.bit_rate

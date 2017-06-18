/// tl_keyframe_length(keyframe)
/// @arg keyframe

var kf = argument0;

if (kf.tl.type = "audio" && kf.value[SOUNDOBJ] && kf.value[SOUNDOBJ].ready)
	return max(0, ((kf.value[SOUNDOBJ].sound_samples / sample_rate) + kf.value[SOUNDEND] - kf.value[SOUNDSTART]) * app.project_tempo)

return 0

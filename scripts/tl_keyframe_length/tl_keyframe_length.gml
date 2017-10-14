/// tl_keyframe_length(keyframe)
/// @arg keyframe

var kf = argument0;

if (kf.timeline.type = e_tl_type.AUDIO && kf.value[e_value.SOUND_OBJ] != null && kf.value[e_value.SOUND_OBJ].ready)
	return max(0, ((kf.value[e_value.SOUND_OBJ].sound_samples / sample_rate) + kf.value[e_value.SOUND_END] - kf.value[e_value.SOUND_START]) * app.project_tempo)

return 0

/// tl_audio_stop()

function tl_audio_stop()
{
	with (obj_keyframe)
	{
		if (audio_exists(sound_play_index))
			audio_stop_sound(sound_play_index)
		sound_play_index = null
	}
}

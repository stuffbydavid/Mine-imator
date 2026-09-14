/// preview_sound_stop()

function preview_sound_stop()
{
	if (audio_exists(sound_play_index))
		audio_stop_sound(sound_play_index)
	
	sound_play_index = null
	sound_playing = false
	update = true
}
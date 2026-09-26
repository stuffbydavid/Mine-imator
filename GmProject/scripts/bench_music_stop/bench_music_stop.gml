/// bench_music_stop([destroy])

function bench_music_stop(destroy = true)
{
	var res, playindex;
	res = bench_settings.music_res
	playindex = bench_settings.music_play_index
	if (audio_exists(playindex))
		audio_stop_sound(playindex)
	
	bench_settings.music_play_index = null
	bench_settings.music_note_next = 0
	bench_settings.music_autoplay = false
	bench_music_mode = false

	with (bench_settings.preview)
	{
		if (sound_play_index = playindex)
		{
			sound_play_index = null
			sound_playing = false
			update = true
		}
	}

	if (destroy)
	{
		bench_settings.music_res = null
		if (bench_settings.sound = res)
			bench_settings.sound = null
		
		with (bench_settings.preview)
		{
			if (select = res)
			{
				select = null
				update = true
			}
		}
		
		if (instance_exists(res))
			with (res)
				instance_destroy()
	}
}

/// res_load_audio()
/// @desc Build peaks from raw audio data.

var fname, prec, soundsamples, sample;
fname = load_folder + "\\" + filename
prec = sample_rate / sample_avg_per_sec

switch (load_stage)
{
	case "open":
	{
		if (sound_index)
			audio_free_buffer_sound(sound_index)
		if (sound_buffer)
			buffer_delete(sound_buffer)
		
		sound_index = null
		sound_buffer = null
		sound_samples = 0
	
		if (movie_audio_file_decode(fname, temp_file) < 0)
		{
			log("Error loading audio")
			error("errorloadaudio")
			with (app)
				load_next()
			return 0
		}
	
		log("Loading audio", fname)
	
		sound_buffer = buffer_load(temp_file)
		sound_index = audio_create_buffer_sound(sound_buffer, buffer_s16, sample_rate, 0, buffer_get_size(sound_buffer), audio_stereo)
		sound_samples = buffer_get_size(sound_buffer) / sample_size
	
		for (var s = 0; s <= sound_samples div prec; s++)
		{
			sound_max_sample[s] = 0
			sound_min_sample[s] = 0
		}
	
		buffer_seek(sound_buffer, 0, 0)
		
		load_stage = "read"
		load_audio_sample = 0
		
		with (app)
		{
			popup_loading.text = text_get("loadaudioread")
			popup_loading.progress = 1 / 5
		}
		break
	}
	
	case "read":
	{
		repeat (sample_rate * 5) // Parse 5 seconds per step
		{
			var ch1, ch2, ind;
			ch1 = buffer_read(sound_buffer, buffer_s16) / sample_max
			ch2 = buffer_read(sound_buffer, buffer_s16) / sample_max
			ind = load_audio_sample div prec
			sound_max_sample[ind] = max(sound_max_sample[ind], ch1, ch2)
			sound_min_sample[ind] = min(sound_min_sample[ind], ch1, ch2)
			load_audio_sample++
	
			if (load_audio_sample >= sound_samples)
			{
				ready = true
				with (app)
				{
					tl_update_length()
					load_next()
				}
				break
			}
		}

		with (app)
			popup_loading.progress = (1 / 5) + (4 / 5) * (load_audio_sample / sound_samples)
			
		break
	}
}
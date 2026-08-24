/// CppSeparate void res_load_audio(ScopeAny)
/// res_load_audio()
/// @desc Build peaks from raw audio data.

function res_load_audio()
{
	var fname, prec;
	fname = load_folder + "/" + filename
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
			
			if (!file_exists_lib(fname))
			{
				with (app)
					load_next()
				return 0
			}
			
			file_delete_lib(temp_file)
			var ret = movie_audio_file_decode(fname, temp_file);
			if (ret < 0)
			{
				log("Error loading audio", ret)
				error("errorloadaudio")
				with (app)
					load_next()
				return 0
			}
			
			log("Loading audio", fname)
			
			// Can't process audio with growing buffer, convert to fixed size
			var buffertemp = buffer_load(temp_file);
			
			sound_buffer = buffer_create(buffer_get_size(buffertemp), buffer_fixed, 2)
			buffer_copy(buffertemp, 0, buffer_get_size(buffertemp), sound_buffer, 0)
			buffer_delete(buffertemp)
			
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
				popup_loading.progress = 0.2
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
				popup_loading.progress = 0.2 + 0.8 * (other.load_audio_sample / other.sound_samples)
			
			break
		}
	}
}

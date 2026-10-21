/// tl_audio_scrub_end(force)
/// @arg force

function tl_audio_scrub_end(force = false)
{
	if (force)
	{
		for (var burstindex = 0; burstindex < 2; burstindex++)
		{
			var sounds = timeline_scrub_sounds[burstindex];
			for (var i = 0; i < array_length(sounds); i++)
				if (audio_exists(sounds[i][0]))
					audio_stop_sound(sounds[i][0])

			timeline_scrub_sounds[burstindex] = []
			timeline_scrub_burst_start_time[burstindex] = null
		}
	}

	timeline_scrub_last_marker = null
	timeline_scrub_last_burst_marker = null
}

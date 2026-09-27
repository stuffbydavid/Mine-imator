/// app_update_audio_scrub()
/// @desc Fades and stops the two overlapping scrub bursts.

function app_update_audio_scrub()
{
	if (timeline_scrub_burst_start_time[0] = null && timeline_scrub_burst_start_time[1] = null)
		return 0

	var now, burstms, fadems;
	now = current_time
	burstms = 96
	fadems = 24

	for (var burstindex = 0; burstindex < 2; burstindex++)
	{
		var starttime, endtime, elapsed, remaining, fadeprogress, gain, sounds;
		starttime = timeline_scrub_burst_start_time[burstindex]
		
		if (starttime = null)
			continue
		
		endtime = starttime + burstms

		elapsed = now - starttime
		remaining = endtime - now
		
		if (elapsed < fadems)
		{
			fadeprogress = clamp(elapsed / fadems, 0, 1)
			gain = 0.5 * (1 - cos(pi * fadeprogress))
		}
		else if (remaining < fadems)
		{
			fadeprogress = clamp(remaining / fadems, 0, 1)
			gain = 0.5 * (1 - cos(pi * fadeprogress))
		}
		else
			gain = 1

		sounds = timeline_scrub_sounds[burstindex]

		for (var i = 0; i < array_length(sounds); i++)
			if (audio_exists(sounds[i][0]))
				audio_sound_gain(sounds[i][0], sounds[i][1] * gain, 0)

		if (remaining <= 0)
		{
			for (var i = 0; i < array_length(sounds); i++)
				if (audio_exists(sounds[i][0]))
					audio_stop_sound(sounds[i][0])

			timeline_scrub_sounds[burstindex] = []
			timeline_scrub_burst_start_time[burstindex] = null
		}
	}
}

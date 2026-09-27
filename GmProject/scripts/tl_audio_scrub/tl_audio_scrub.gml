/// tl_audio_scrub(markerpos)
/// @desc Plays overlapping audio bursts while the timeline marker is dragged.
/// @arg markerpos

function tl_audio_scrub(markerpos)
{
	if (timeline_playing && window_busy != "timelinemarker")
		return 0

	var now, burstms, throttlems, dir, burstindex, lastbursttime, sounds;
	now = current_time
	burstms = 96
	throttlems = 72

	if (timeline_scrub_last_marker = null)
	{
		timeline_scrub_last_marker = markerpos
		timeline_scrub_last_burst_marker = markerpos
		return 0
	}

	dir = sign(markerpos - timeline_scrub_last_marker)
	timeline_scrub_last_marker = markerpos

	lastbursttime = timeline_scrub_burst_start_time[timeline_scrub_burst_index]
	if (dir = 0 || abs(markerpos - timeline_scrub_last_burst_marker) / project_tempo <= 0.002 || (lastbursttime != null && now - lastbursttime < throttlems))
		return 0

	burstindex = 1 - timeline_scrub_burst_index
	sounds = timeline_scrub_sounds[burstindex]

	for (var i = 0; i < array_length(sounds); i++)
		if (audio_exists(sounds[i][0]))
			audio_stop_sound(sounds[i][0])

	sounds = []

	with (obj_timeline)
	{
		if (type != e_tl_type.AUDIO_TRACK || hide)
			continue

		for (var k = 0; k < ds_list_size(keyframe_list); k++)
		{
			with (keyframe_list[|k])
			{
				var sound, length, soundduration, offset, pitch, playindex;
				sound = value[e_value.SOUND_OBJ]
				if (sound = null || !sound.ready)
					continue

				length = tl_keyframe_length(id)
				
				if (position + length < markerpos)
					continue
				
				if (position > markerpos)
					break

				soundduration = sound.sound_samples / sample_rate
				pitch = value[e_value.SOUND_PITCH]
				offset = (value[e_value.SOUND_START] + (markerpos - position) / app.project_tempo) * pitch
				offset = offset mod soundduration

				if (dir < 0)
					offset = max(0, offset - burstms / 1000 * pitch)

				playindex = audio_play_sound(sound.sound_index, 0, value[e_value.SOUND_END] > 0)
				audio_pause_sound(playindex)
				audio_sound_pitch(playindex, pitch)
				audio_sound_set_track_position(playindex, clamp(offset, 0, max(0, soundduration - 0.001)))
				audio_sound_gain(playindex, 0, 0)
				audio_resume_sound(playindex)

				// Store the sound instance and its maximum volume for the fade update.
				sounds[array_length(sounds)] = [playindex, value[e_value.SOUND_VOLUME]]
			}
		}
	}

	timeline_scrub_burst_index = burstindex
	timeline_scrub_sounds[burstindex] = sounds
	timeline_scrub_burst_start_time[burstindex] = now
	timeline_scrub_last_burst_marker = markerpos
}

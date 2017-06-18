/// action_toolbar_play_start()
/// @desc Plays sounds and fires particles on the marker.

audio_stop_all()

with (obj_timeline)
{
	if (type = "audio" && !hide && !app.exportmovie)
	{
		for (var k = 0; k < keyframe_amount; k++)
		{
			with (keyframe[k])
			{
				sound_play_index = null
				
				if (!value[SOUNDOBJ] || !value[SOUNDOBJ].ready)
					continue
					
				if (pos + tl_keyframe_length(id) < app.timeline_marker)
					continue
				
				if (pos > app.timeline_marker)
					break
					
				sound_play_index = audio_play_sound(value[SOUNDOBJ].sound_index, 0, true)
				audio_sound_set_track_position(sound_play_index, (value[SOUNDSTART] + (app.timeline_marker - pos) / app.project_tempo) mod (value[SOUNDOBJ].sound_samples / sample_rate))
				audio_sound_gain(sound_play_index, value[SOUNDVOLUME], 0)
			}
		}
	}
	else if (type = "particles")
	{
		for (var k = 0; k < keyframe_amount; k++)
		{
			if (keyframe[k].value[SPAWN] && keyframe[k].pos = app.timeline_marker)
			{
				fire = true
				break
			}
		}
	}
}

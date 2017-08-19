/// action_toolbar_play_start()
/// @desc Plays sounds and fires particles on the marker.

audio_stop_all()

with (obj_timeline)
{
	if (type = "audio" && !hide && !app.exportmovie)
	{
		for (var k = 0; k < ds_list_size(keyframe_list); k++)
		{
			with (keyframe_list[|k])
			{
				sound_play_index = null
				
				if (!value[SOUNDOBJ] || !value[SOUNDOBJ].ready)
					continue
					
				if (position + tl_keyframe_length(id) < app.timeline_marker)
					continue
				
				if (position > app.timeline_marker)
					break
					
				sound_play_index = audio_play_sound(value[SOUNDOBJ].sound_index, 0, true)
				audio_sound_set_track_position(sound_play_index, (value[SOUNDSTART] + (app.timeline_marker - position) / app.project_tempo) mod (value[SOUNDOBJ].sound_samples / sample_rate))
				audio_sound_gain(sound_play_index, value[SOUNDVOLUME], 0)
			}
		}
	}
	else if (type = "particles")
	{
		for (var k = 0; k < ds_list_size(keyframe_list); k++)
		{
			if (keyframe_list[|k].value[SPAWN] && keyframe_list[|k].position = app.timeline_marker)
			{
				fire = true
				break
			}
		}
	}
}

/// action_tl_play_start()
/// @desc Plays sounds and fires particles on the marker.

function action_tl_play_start()
{
	audio_stop_all()
	
	with (obj_timeline)
	{
		if (type = e_tl_type.AUDIO && !hide && app.window_state != "export_movie")
		{
			for (var k = 0; k < ds_list_size(keyframe_list); k++)
			{
				with (keyframe_list[|k])
				{
					sound_play_index = null
					
					if (value[e_value.SOUND_OBJ] = null || !value[e_value.SOUND_OBJ].ready)
						continue
					
					if (position + tl_keyframe_length(id) < app.timeline_marker)
						continue
					
					if (position > app.timeline_marker)
						break
					
					sound_play_index = audio_play_sound(value[e_value.SOUND_OBJ].sound_index, 0, false)
					audio_sound_set_track_position(sound_play_index, (value[e_value.SOUND_START] + (app.timeline_marker - position) / app.project_tempo) mod (value[e_value.SOUND_OBJ].sound_samples / sample_rate))
					audio_sound_gain(sound_play_index, value[e_value.SOUND_VOLUME], 0)
				}
			}
		}
		else if (type = e_temp_type.PARTICLE_SPAWNER)
		{
			for (var k = 0; k < ds_list_size(keyframe_list); k++)
			{
				if (keyframe_list[|k].value[e_value.SPAWN] && keyframe_list[|k].position = app.timeline_marker)
				{
					fire = true
					break
				}
			}
		}
	}
}

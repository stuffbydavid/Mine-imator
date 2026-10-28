/// @desc Updates the values.

function tl_update_values()
{
	if (!animated)
	{
		keyframe_prev = null
		keyframe_current = null
		keyframe_next = null
		keyframe_animate = false
		keyframe_value_cache_valid = false
		
		return 0
	}

	keyframe_prev = keyframe_current
	keyframe_current = null
	keyframe_next = null
	
	// Find the first keyframe after the marker in the ordered list
	// Search fresh each time so edits, reverse playback and seeks need no cursor invalidation
	var keyframes, left, right;
	keyframes = ds_list_size(keyframe_list)
	left = 0
	right = keyframes
	while (left < right)
	{
		var middle = floor((left + right) / 2);
		if (keyframe_list[|middle].position > app.timeline_marker)
			right = middle
		else
			left = middle + 1
	}
	
	if (left > 0)
		keyframe_current = keyframe_list[|left - 1]
	if (keyframes > 0)
		keyframe_next = keyframe_list[|min(left, keyframes - 1)]

	keyframe_progress = tl_update_values_progress(app.timeline_marker)
	keyframe_animate = (keyframe_current && keyframe_next && keyframe_current != keyframe_next)
	
	var cachevalues = (app.timeline_playing && app.window_busy = "" && !app.history_resource_update);
	keyframe_value_cache_reuse = (cachevalues && keyframe_value_cache_valid && !update_matrix &&
		keyframe_value_cache_current = keyframe_current && keyframe_value_cache_next = keyframe_next &&
		keyframe_value_cache_animate = keyframe_animate && keyframe_value_cache_start = app.timeline_playing_start_time)
	
	if (!keyframe_value_cache_reuse)
		keyframe_value_cache_channels = []

	// Transition
	keyframe_progress_ease = 0
	tl_update_values_batch(true)
	
	keyframe_transition = value[e_value.TRANSITION]
	
	if (keyframe_transition = "bezier")
		keyframe_progress_ease = ease_bezier_curve([ 0, 0 ], [ value[e_value.EASE_IN_X], value[e_value.EASE_IN_Y] ], [ value[e_value.EASE_OUT_X], value[e_value.EASE_OUT_Y] ], [ 1, 1 ], keyframe_progress)
	else
		keyframe_progress_ease = ease(keyframe_transition, keyframe_progress)
	
	// Evaluate enabled channels in one native batch
	tl_update_values_batch(false)
	keyframe_value_cache_valid = cachevalues
	keyframe_value_cache_current = keyframe_current
	keyframe_value_cache_next = keyframe_next
	keyframe_value_cache_animate = keyframe_animate
	keyframe_value_cache_start = app.timeline_playing_start_time
	
	// Play sounds
	if (type = e_tl_type.AUDIO_TRACK && !hide && app.timeline_marker > app.timeline_marker_previous && app.timeline_playing && app.window_busy != "timeline/marker")
	{
		// Play new sound
		if (keyframe_current)
		{
			if (value[e_value.SOUND_OBJ] && value[e_value.SOUND_OBJ].ready && keyframe_prev != keyframe_current && keyframe_current.sound_play_index = null)
			{
				keyframe_current.sound_play_index = audio_play_sound(value[e_value.SOUND_OBJ].sound_index, 0, (value[e_value.SOUND_END] > 0 ? true : false))
				
				audio_sound_pitch(keyframe_current.sound_play_index, value[e_value.SOUND_PITCH])
				audio_sound_set_track_position(keyframe_current.sound_play_index, (value[e_value.SOUND_START] mod (value[e_value.SOUND_OBJ].sound_samples / sample_rate)) * value[e_value.SOUND_PITCH])
				audio_sound_gain(keyframe_current.sound_play_index, value[e_value.SOUND_VOLUME], 0)
			}
			
			// Check if passed sounds should be stopped
			for (var k = 0; k < ds_list_size(keyframe_list); k++)
			{
				with (keyframe_list[|k])
				{
					if (sound_play_index && app.timeline_marker > position + tl_keyframe_length(id))
					{
						audio_stop_sound(sound_play_index)
						sound_play_index = null
					}
				}
				
				if (keyframe_current = keyframe_list[|k])
					break
			}
		}
	}
	
	// Update particle spawners
	if (type = e_tl_type.PARTICLE_SPAWNER && app.timeline_marker > app.timeline_marker_previous && keyframe_prev != keyframe_current)
	{
		// Fire particles
		if (!temp.pc_spawn_constant && value[e_value.SPAWN] && !value[e_value.FREEZE])
			fire = true
		
		// Clear particles
		if (value[e_value.CLEAR])
			particle_spawner_clear()
	}
}

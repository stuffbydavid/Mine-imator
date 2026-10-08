/// @desc Updates the values.

function tl_update_values()
{
	if (!animated)
	{
		keyframe_prev = null
		keyframe_current = null
		keyframe_next = null
		keyframe_current_values = null
		keyframe_next_values = null
		keyframe_animate = false
		
		return 0
	}

	keyframe_prev = keyframe_current
	keyframe_current = null
	keyframe_next = null
	keyframe_current_values = null
	keyframe_next_values = null
	
	// Find keyframes
	for (var k = 0; k < ds_list_size(keyframe_list); k++)
	{
		keyframe_next = keyframe_list[|k]
		if (keyframe_next.position > app.timeline_marker)
			break
		
		keyframe_current = keyframe_next
	}
	
	keyframe_progress = tl_update_values_progress(app.timeline_marker)
	keyframe_animate = (keyframe_current && keyframe_next && keyframe_current != keyframe_next)
	
	// Save 'value' arrays from keyframes to speed up easing
	if (keyframe_current != null)
		keyframe_current_values = keyframe_current.value
	
	if (keyframe_next != null)
		keyframe_next_values = keyframe_next.value
	
	// Transition
	keyframe_progress_ease = 0
	for (var vid = e_value.TRANSITION; vid <= e_value.EASE_OUT_Y; vid++)
		tl_update_values_ease(vid)
	
	keyframe_transition = value[e_value.TRANSITION]
	
	if (keyframe_transition = "bezier")
		keyframe_progress_ease = ease_bezier_curve([ 0, 0 ], [ value[e_value.EASE_IN_X], value[e_value.EASE_IN_Y] ], [ value[e_value.EASE_OUT_X], value[e_value.EASE_OUT_Y] ], [ 1, 1 ], keyframe_progress)
	else
		keyframe_progress_ease = ease(keyframe_transition, keyframe_progress)
	
	// Position
	if (value_type[e_value_type.TRANSFORM_POS])
	{
		for (var vid = e_value.POS_X; vid <= e_value.POS_Z; vid++)
			tl_update_values_ease(vid)
		
		if (type != e_tl_type.PATH && type != e_tl_type.PATH_POINT)
			for (var vid = e_value.PATH_OBJ; vid <= e_value.PATH_OFFSET; vid++)
				tl_update_values_ease(vid)
	}
	
	// Rotation
	if (value_type[e_value_type.TRANSFORM_ROT])
		for (var vid = e_value.ROT_X; vid <= e_value.ROT_Z; vid++)
			tl_update_values_ease(vid)
	
	// Scale
	if (value_type[e_value_type.TRANSFORM_SCA])
		for (var vid = e_value.SCA_X; vid <= e_value.SCA_Z; vid++)
			tl_update_values_ease(vid)
	
	// Bend
	if (value_type[e_value_type.TRANSFORM_BEND])
	{
		for (var vid = e_value.BEND_ANGLE_X; vid <= e_value.BEND_ANGLE_Z; vid++)
			tl_update_values_ease(vid)
		
		for (var vid = e_value.IK_TARGET; vid <= e_value.IK_ANGLE_OFFSET; vid++)
			tl_update_values_ease(vid)
	}
	
	// Path point
	if (value_type[e_value_type.TRANSFORM_PATH_POINT])
		for (var vid = e_value.PATH_POINT_ANGLE; vid <= e_value.PATH_POINT_SCALE; vid++)
			tl_update_values_ease(vid)
	
	// Color
	if (value_type[e_value_type.MATERIAL_COLOR])
		for (var vid = e_value.ALPHA; vid <= e_value.WIND_INFLUENCE; vid++)
			tl_update_values_ease(vid)
	
	// Particles
	if (value_type[e_value_type.PARTICLES])
		for (var vid = e_value.SPAWN; vid <= e_value.FORCE_VORTEX; vid++)
			tl_update_values_ease(vid)
	
	// Light
	if (value_type[e_value_type.LIGHT])
	{
		for (var vid = e_value.LIGHT_COLOR; vid <= e_value.LIGHT_FADE_SIZE; vid++)
			tl_update_values_ease(vid)
		
		// Spotlight
		if (value_type[e_value_type.SPOTLIGHT])
			for (var vid = e_value.LIGHT_SPOT_RADIUS; vid <= e_value.LIGHT_SPOT_SHARPNESS; vid++)
				tl_update_values_ease(vid)
	}
	
	// Camera
	if (value_type[e_value_type.CAMERA])
		for (var vid = e_value.CAM_FOV; vid <= e_value.CAM_ROTATE_ANGLE_Z; vid++)
			tl_update_values_ease(vid)
	
	// Camera effects
	if (value_type[e_value_type.CAMERA_EFFECT])
	{
		var fxrange = camera_effect_value_range_list[|camera_effect_type];
		for (var vid = fxrange[0]; vid <= fxrange[1]; vid++)
			if (camera_effect_type != e_cam_fx.FADE || vid != e_value.GLOW_COLOR)
				tl_update_values_ease(vid)
		
		if (camera_effect_type_use_aperture(camera_effect_type))
			for (var vid = e_value.CAM_FX_BLADE_AMOUNT; vid <= e_value.CAM_FX_BLADE_STRETCH; vid++)
				tl_update_values_ease(vid)
		
		if (camera_effect_type = e_cam_fx.COLOR_CORRECTION)
			for (var vid = e_value.RGB_ADD; vid <= e_value.HSB_MUL; vid++)
				tl_update_values_ease(vid)
		
		if (camera_effect_type = e_cam_fx.LENS_DIRT)
			tl_update_values_ease(e_value.TEXTURE_OBJ)
	}
	
	// Background
	if (value_type[e_value_type.ENVIRONMENT])
		for (var vid = e_value.ENV_IMAGE_SHOW; vid <= e_value.ENV_BRIGHTNESS; vid++)
			tl_update_values_ease(vid)
	
	// Texture
	if (value_type[e_value_type.MATERIAL_TEXTURE] || value_type[e_value_type.ITEM])
		for (var vid = e_value.TEXTURE_OBJ; vid <= e_value.TEXTURE_NORMAL_OBJ; vid++)
			tl_update_values_ease(vid)
	
	// Sound
	if (value_type[e_value_type.SOUND])
		for (var vid = e_value.SOUND_OBJ; vid <= e_value.SOUND_END; vid++)
			tl_update_values_ease(vid)
	
	// Text
	if (value_type[e_value_type.TEXT])
		for (var vid = e_value.TEXT; vid <= e_value.TEXT_CUSTOM_OUTLINE; vid++)
			tl_update_values_ease(vid)
	
	// Item
	if (value_type[e_value_type.ITEM])
		for (var vid = e_value.CUSTOM_ITEM_SLOT; vid <= e_value.ITEM_SLOT; vid++)
			tl_update_values_ease(vid)
	
	// Visible
	tl_update_values_ease(e_value.VISIBLE)
	
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

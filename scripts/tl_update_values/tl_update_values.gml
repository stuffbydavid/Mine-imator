/// tl_update_values()
/// @desc Updates the values.

function tl_update_values()
{
	var oldkf = keyframe_current;
	keyframe_current = null
	keyframe_next = null
	
	// Find keyframes
	var kflistsize = ds_list_size(keyframe_list);
	
	for (var k = 0; k < kflistsize; k++)
	{
		keyframe_next = keyframe_list[|k]
		if (keyframe_next.position > app.timeline_marker)
			break
		keyframe_current = keyframe_next
	}
	
	// Seamless region looping
	var seamlessloop, loopstart, loopend;
	seamlessloop = (app.timeline_repeat && app.timeline_seamless_repeat && app.timeline_marker >= loopstart && app.timeline_marker < loopend)
	
	if (app.timeline_region_start != null)
	{
		loopstart = app.timeline_region_start
		loopend = app.timeline_region_end
	}
	else
	{
		loopstart = 0
		loopend = app.timeline_length
	}
	
	if (!seamlessloop)
	{
		// Get progress
		var p = 0;
		if (keyframe_current && keyframe_next && keyframe_current != keyframe_next)
			p = (app.timeline_marker - keyframe_current.position) / (keyframe_next.position - keyframe_current.position);
	}
	else
	{
		// Change keyframes so the animation is seamless
		var lastkf, loopnext, loopprev;
		lastkf = ds_list_size(keyframe_list) - 1
		loopnext = false
		loopprev = false
		
		if (keyframe_next = keyframe_current || keyframe_next.position > loopend) // Continue into the first keyframe
		{
			// Get first keyframe in timeline region
			for (var k = 0; k < kflistsize; k++)
			{
				var kf = keyframe_list[|k];
				
				if (kf.position < loopstart || kf.position > loopend)
					continue
				else
				{
					if (kf.position < keyframe_next.position)
						keyframe_next = kf
				}
			}
			
			loopnext = true
		}
		else if (keyframe_current = null || keyframe_current.position < loopstart) // Continue from last keyframe
		{
			// Get last keyframe in timeline region
			for (var k = 0; k < kflistsize; k++)
			{
				var kf = keyframe_list[|k];
				
				if (kf.position < loopstart || kf.position > loopend)
					continue
				else
				{
					if (keyframe_current = null || kf.position > keyframe_current.position)
						keyframe_current = kf
				}
			}
			
			loopprev = true
		}
		
		// Get progress
		var p, regionsize;
		p = 0
		var regionsize = loopend - loopstart;
		if (keyframe_current && keyframe_next && keyframe_current != keyframe_next)
		{
			if (loopnext)
				p = (app.timeline_marker - keyframe_current.position) / ((keyframe_next.position + regionsize) - keyframe_current.position)
			else if (loopprev)
				p = ((app.timeline_marker + regionsize) - keyframe_current.position) / ((keyframe_next.position + regionsize) - keyframe_current.position)
			else
				p = (app.timeline_marker - keyframe_current.position) / (keyframe_next.position - keyframe_current.position)
		}
		else
			keyframe_current = keyframe_next
	}
	
	keyframe_animate = (keyframe_current != null && keyframe_next != null && keyframe_current != keyframe_next)
	keyframe_use_next = (keyframe_next != null)
	
	// Marker is past all keyframes, no need to update
	if (app.timeline_playing && (oldkf = keyframe_current) && (keyframe_current = keyframe_list[|ds_list_size(keyframe_list) - 1]))
		return 0
	
	// Transition
	keyframe_transition = "instant"
	keyframe_progress_ease = 0
	
	tl_update_values_ease(e_value.TRANSITION)
	var trans = value[e_value.TRANSITION];
	
	keyframe_transition = trans
	keyframe_progress = p
	keyframe_progress_ease = ease(keyframe_transition, keyframe_progress)
	
	// Position
	if (value_type[e_value_type.TRANSFORM_POS])
	{
		tl_update_values_ease(e_value.POS_X)
		tl_update_values_ease(e_value.POS_Y)
		tl_update_values_ease(e_value.POS_Z)
	}
	
	// Rotation
	if (value_type[e_value_type.TRANSFORM_ROT])
	{
		tl_update_values_ease(e_value.ROT_X)
		tl_update_values_ease(e_value.ROT_Y)
		tl_update_values_ease(e_value.ROT_Z)
	}
	
	// Scale
	if (value_type[e_value_type.TRANSFORM_SCA])
	{
		tl_update_values_ease(e_value.SCA_X)
		tl_update_values_ease(e_value.SCA_Y)
		tl_update_values_ease(e_value.SCA_Z)
	}
	
	// Bend
	if (value_type[e_value_type.TRANSFORM_BEND])
	{
		tl_update_values_ease(e_value.BEND_ANGLE_X)
		tl_update_values_ease(e_value.BEND_ANGLE_Y)
		tl_update_values_ease(e_value.BEND_ANGLE_Z)
	}
	
	// Color
	if (value_type[e_value_type.MATERIAL_COLOR])
	{
		tl_update_values_ease(e_value.ALPHA)
		tl_update_values_ease(e_value.RGB_ADD)
		tl_update_values_ease(e_value.RGB_SUB)
		tl_update_values_ease(e_value.RGB_MUL)
		tl_update_values_ease(e_value.HSB_ADD)
		tl_update_values_ease(e_value.HSB_SUB)
		tl_update_values_ease(e_value.HSB_MUL)
		tl_update_values_ease(e_value.MIX_COLOR)
		tl_update_values_ease(e_value.GLOW_COLOR)
		tl_update_values_ease(e_value.MIX_PERCENT)
		tl_update_values_ease(e_value.BRIGHTNESS)
		tl_update_values_ease(e_value.METALLIC)
		tl_update_values_ease(e_value.ROUGHNESS)
		tl_update_values_ease(e_value.SUBSURFACE)
		tl_update_values_ease(e_value.SUBSURFACE_RADIUS_RED)
		tl_update_values_ease(e_value.SUBSURFACE_RADIUS_GREEN)
		tl_update_values_ease(e_value.SUBSURFACE_RADIUS_BLUE)
		tl_update_values_ease(e_value.SUBSURFACE_COLOR)
	}
	
	// Particles
	if (value_type[e_value_type.PARTICLES])
	{
		tl_update_values_ease(e_value.SPAWN)
		tl_update_values_ease(e_value.FREEZE)
		tl_update_values_ease(e_value.CLEAR)
		tl_update_values_ease(e_value.CUSTOM_SEED)
		tl_update_values_ease(e_value.SEED)
		tl_update_values_ease(e_value.ATTRACTOR)
		tl_update_values_ease(e_value.FORCE)
	}
	
	// Light
	if (value_type[e_value_type.LIGHT])
	{
		tl_update_values_ease(e_value.LIGHT_COLOR)
		tl_update_values_ease(e_value.LIGHT_STRENGTH)
		tl_update_values_ease(e_value.LIGHT_SPECULAR_STRENGTH)
		tl_update_values_ease(e_value.LIGHT_SIZE)
		tl_update_values_ease(e_value.LIGHT_RANGE)
		tl_update_values_ease(e_value.LIGHT_RANGE)
		tl_update_values_ease(e_value.LIGHT_FADE_SIZE)
		
		// Spotlight
		if (value_type[e_value_type.SPOTLIGHT])
		{
			tl_update_values_ease(e_value.LIGHT_SPOT_RADIUS)
			tl_update_values_ease(e_value.LIGHT_SPOT_SHARPNESS)
		}
	}
	
	// Camera
	if (value_type[e_value_type.CAMERA])
	{
		tl_update_values_ease(e_value.CAM_FOV)
		tl_update_values_ease(e_value.CAM_NEAR)
		tl_update_values_ease(e_value.CAM_FAR)
		
		tl_update_values_ease(e_value.CAM_BLADE_AMOUNT)
		tl_update_values_ease(e_value.CAM_BLADE_ANGLE)
		
		tl_update_values_ease(e_value.CAM_ROTATE)
		tl_update_values_ease(e_value.CAM_ROTATE_DISTANCE)
		tl_update_values_ease(e_value.CAM_ROTATE_ANGLE_XY)
		tl_update_values_ease(e_value.CAM_ROTATE_ANGLE_Z)
		
		tl_update_values_ease(e_value.CAM_SHAKE)
		tl_update_values_ease(e_value.CAM_SHAKE_STRENGTH)
		tl_update_values_ease(e_value.CAM_SHAKE_VERTICAL_OFFSET)
		tl_update_values_ease(e_value.CAM_SHAKE_VERTICAL_SPEED)
		tl_update_values_ease(e_value.CAM_SHAKE_VERTICAL_STRENGTH)
		tl_update_values_ease(e_value.CAM_SHAKE_HORIZONTAL_OFFSET)
		tl_update_values_ease(e_value.CAM_SHAKE_HORIZONTAL_SPEED)
		tl_update_values_ease(e_value.CAM_SHAKE_HORIZONTAL_STRENGTH)
		
		tl_update_values_ease(e_value.CAM_DOF)
		tl_update_values_ease(e_value.CAM_DOF_DEPTH)
		tl_update_values_ease(e_value.CAM_DOF_RANGE)
		tl_update_values_ease(e_value.CAM_DOF_FADE_SIZE)
		tl_update_values_ease(e_value.CAM_DOF_BLUR_SIZE)
		tl_update_values_ease(e_value.CAM_DOF_BLUR_RATIO)
		tl_update_values_ease(e_value.CAM_DOF_BIAS)
		tl_update_values_ease(e_value.CAM_DOF_THRESHOLD)
		tl_update_values_ease(e_value.CAM_DOF_GAIN)
		tl_update_values_ease(e_value.CAM_DOF_FRINGE)
		tl_update_values_ease(e_value.CAM_DOF_FRINGE_ANGLE_RED)
		tl_update_values_ease(e_value.CAM_DOF_FRINGE_ANGLE_GREEN)
		tl_update_values_ease(e_value.CAM_DOF_FRINGE_ANGLE_BLUE)
		tl_update_values_ease(e_value.CAM_DOF_FRINGE_RED)
		tl_update_values_ease(e_value.CAM_DOF_FRINGE_GREEN)
		tl_update_values_ease(e_value.CAM_DOF_FRINGE_BLUE)
		
		tl_update_values_ease(e_value.CAM_BLOOM)
		tl_update_values_ease(e_value.CAM_BLOOM_THRESHOLD)
		tl_update_values_ease(e_value.CAM_BLOOM_INTENSITY)
		tl_update_values_ease(e_value.CAM_BLOOM_RADIUS)
		tl_update_values_ease(e_value.CAM_BLOOM_RATIO)
		tl_update_values_ease(e_value.CAM_BLOOM_BLEND)
		
		tl_update_values_ease(e_value.CAM_LENS_DIRT)
		tl_update_values_ease(e_value.TEXTURE_OBJ)
		tl_update_values_ease(e_value.CAM_LENS_DIRT_BLOOM)
		tl_update_values_ease(e_value.CAM_LENS_DIRT_GLOW)
		tl_update_values_ease(e_value.CAM_LENS_DIRT_RADIUS)
		tl_update_values_ease(e_value.CAM_LENS_DIRT_INTENSITY)
		tl_update_values_ease(e_value.CAM_LENS_DIRT_POWER)
		
		tl_update_values_ease(e_value.CAM_COLOR_CORRECTION)
		tl_update_values_ease(e_value.CAM_CONTRAST)
		tl_update_values_ease(e_value.CAM_BRIGHTNESS)
		tl_update_values_ease(e_value.CAM_SATURATION)
		tl_update_values_ease(e_value.CAM_VIBRANCE)
		tl_update_values_ease(e_value.CAM_COLOR_BURN)
		
		tl_update_values_ease(e_value.CAM_GRAIN)
		tl_update_values_ease(e_value.CAM_GRAIN_STRENGTH)
		tl_update_values_ease(e_value.CAM_GRAIN_SATURATION)
		tl_update_values_ease(e_value.CAM_GRAIN_SIZE)
		
		tl_update_values_ease(e_value.CAM_VIGNETTE)
		tl_update_values_ease(e_value.CAM_VIGNETTE_RADIUS)
		tl_update_values_ease(e_value.CAM_VIGNETTE_SOFTNESS)
		tl_update_values_ease(e_value.CAM_VIGNETTE_STRENGTH)
		tl_update_values_ease(e_value.CAM_VIGNETTE_COLOR)
		
		tl_update_values_ease(e_value.CAM_CA)
		tl_update_values_ease(e_value.CAM_CA_BLUR_AMOUNT)
		tl_update_values_ease(e_value.CAM_CA_DISTORT_CHANNELS)
		tl_update_values_ease(e_value.CAM_CA_RED_OFFSET)
		tl_update_values_ease(e_value.CAM_CA_GREEN_OFFSET)
		tl_update_values_ease(e_value.CAM_CA_BLUE_OFFSET)
		
		tl_update_values_ease(e_value.CAM_DISTORT)
		tl_update_values_ease(e_value.CAM_DISTORT_REPEAT)
		tl_update_values_ease(e_value.CAM_DISTORT_AMOUNT)
		
		tl_update_values_ease(e_value.CAM_WIDTH)
		tl_update_values_ease(e_value.CAM_HEIGHT)
		tl_update_values_ease(e_value.CAM_SIZE_USE_PROJECT)
		tl_update_values_ease(e_value.CAM_SIZE_KEEP_ASPECT_RATIO)
	}
	
	// Background
	if (value_type[e_value_type.BACKGROUND])
	{
		tl_update_values_ease(e_value.BG_IMAGE_SHOW)
		tl_update_values_ease(e_value.BG_IMAGE_ROTATION)
		tl_update_values_ease(e_value.BG_SKY_MOON_PHASE)
		tl_update_values_ease(e_value.BG_SKY_TIME)
		tl_update_values_ease(e_value.BG_SKY_ROTATION)
		tl_update_values_ease(e_value.BG_SUNLIGHT_STRENGTH)
		tl_update_values_ease(e_value.BG_SUNLIGHT_ANGLE)
		tl_update_values_ease(e_value.BG_TWILIGHT)
		tl_update_values_ease(e_value.BG_DESATURATE_NIGHT)
		tl_update_values_ease(e_value.BG_DESATURATE_NIGHT_AMOUNT)
		tl_update_values_ease(e_value.BG_SKY_CLOUDS_SHOW)
		tl_update_values_ease(e_value.BG_SKY_CLOUDS_SPEED)
		tl_update_values_ease(e_value.BG_SKY_CLOUDS_HEIGHT)
		tl_update_values_ease(e_value.BG_SKY_CLOUDS_OFFSET)
		tl_update_values_ease(e_value.BG_GROUND_SHOW)
		tl_update_values_ease(e_value.BG_GROUND_SLOT)
		tl_update_values_ease(e_value.BG_SKY_COLOR)
		tl_update_values_ease(e_value.BG_SKY_CLOUDS_COLOR)
		tl_update_values_ease(e_value.BG_SUNLIGHT_COLOR)
		tl_update_values_ease(e_value.BG_AMBIENT_COLOR)
		tl_update_values_ease(e_value.BG_NIGHT_COLOR)
		tl_update_values_ease(e_value.BG_GRASS_COLOR)
		tl_update_values_ease(e_value.BG_FOLIAGE_COLOR)
		tl_update_values_ease(e_value.BG_WATER_COLOR)
		tl_update_values_ease(e_value.BG_LEAVES_OAK_COLOR)
		tl_update_values_ease(e_value.BG_LEAVES_SPRUCE_COLOR)
		tl_update_values_ease(e_value.BG_LEAVES_BIRCH_COLOR)
		tl_update_values_ease(e_value.BG_LEAVES_JUNGLE_COLOR)
		tl_update_values_ease(e_value.BG_LEAVES_ACACIA_COLOR)
		tl_update_values_ease(e_value.BG_LEAVES_DARK_OAK_COLOR)
		tl_update_values_ease(e_value.BG_VOLUMETRIC_FOG)
		tl_update_values_ease(e_value.BG_VOLUMETRIC_FOG_SCATTER)
		tl_update_values_ease(e_value.BG_VOLUMETRIC_FOG_DENSITY)
		tl_update_values_ease(e_value.BG_VOLUMETRIC_FOG_HEIGHT)
		tl_update_values_ease(e_value.BG_VOLUMETRIC_FOG_HEIGHT_FADE)
		tl_update_values_ease(e_value.BG_VOLUMETRIC_FOG_NOISE_SCALE)
		tl_update_values_ease(e_value.BG_VOLUMETRIC_FOG_NOISE_CONTRAST)
		tl_update_values_ease(e_value.BG_VOLUMETRIC_FOG_WIND)
		tl_update_values_ease(e_value.BG_VOLUMETRIC_FOG_COLOR)
		tl_update_values_ease(e_value.BG_FOG_SHOW)
		tl_update_values_ease(e_value.BG_FOG_SKY)
		tl_update_values_ease(e_value.BG_FOG_CUSTOM_COLOR)
		tl_update_values_ease(e_value.BG_FOG_COLOR)
		tl_update_values_ease(e_value.BG_FOG_CUSTOM_OBJECT_COLOR)
		tl_update_values_ease(e_value.BG_FOG_OBJECT_COLOR)
		tl_update_values_ease(e_value.BG_FOG_DISTANCE)
		tl_update_values_ease(e_value.BG_FOG_SIZE)
		tl_update_values_ease(e_value.BG_FOG_HEIGHT)
		tl_update_values_ease(e_value.BG_WIND)
		tl_update_values_ease(e_value.BG_WIND_STRENGTH)
		tl_update_values_ease(e_value.BG_WIND_SPEED)
		tl_update_values_ease(e_value.BG_WIND_DIRECTION)
		tl_update_values_ease(e_value.BG_WIND_DIRECTIONAL_SPEED)
		tl_update_values_ease(e_value.BG_WIND_DIRECTIONAL_STRENGTH)
		tl_update_values_ease(e_value.BG_TEXTURE_ANI_SPEED)
	}
	
	// Texture
	if (value_type[e_value_type.MATERIAL_TEXTURE])
	{
		tl_update_values_ease(e_value.TEXTURE_OBJ)
		tl_update_values_ease(e_value.TEXTURE_MATERIAL_OBJ)
		tl_update_values_ease(e_value.TEXTURE_NORMAL_OBJ)
	}
	
	// Sound
	if (value_type[e_value_type.SOUND])
	{
		tl_update_values_ease(e_value.SOUND_OBJ)
		tl_update_values_ease(e_value.SOUND_VOLUME)
		tl_update_values_ease(e_value.SOUND_START)
		tl_update_values_ease(e_value.SOUND_END)
	}
	
	// Text
	if (value_type[e_value_type.TEXT])
	{
		tl_update_values_ease(e_value.TEXT)
		tl_update_values_ease(e_value.TEXT_FONT)
		tl_update_values_ease(e_value.TEXT_HALIGN)
		tl_update_values_ease(e_value.TEXT_VALIGN)
		tl_update_values_ease(e_value.TEXT_AA)
	}
	
	// Item
	if (value_type[e_value_type.ITEM])
	{
		tl_update_values_ease(e_value.CUSTOM_ITEM_SLOT)
		tl_update_values_ease(e_value.ITEM_SLOT)
		tl_update_values_ease(e_value.TEXTURE_OBJ)
		tl_update_values_ease(e_value.TEXTURE_MATERIAL_OBJ)
		tl_update_values_ease(e_value.TEXTURE_NORMAL_OBJ)
	}
	
	// Visible
	tl_update_values_ease(e_value.VISIBLE)
	
	// Play sounds
	if (type = e_tl_type.AUDIO && !hide && app.timeline_marker > app.timeline_marker_previous && app.timeline_playing)
	{
		// Play new sound
		if (keyframe_current)
		{
			if (value[e_value.SOUND_OBJ] && value[e_value.SOUND_OBJ].ready && oldkf != keyframe_current)
			{
				keyframe_current.sound_play_index = audio_play_sound(value[e_value.SOUND_OBJ].sound_index, 0, false);
				audio_sound_set_track_position(keyframe_current.sound_play_index, value[e_value.SOUND_START] mod (value[e_value.SOUND_OBJ].sound_samples / sample_rate))
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
	if (type = e_temp_type.PARTICLE_SPAWNER && app.timeline_marker > app.timeline_marker_previous && oldkf != keyframe_current)
	{
		// Fire particles
		if (!temp.pc_spawn_constant && value[e_value.SPAWN] && !value[e_value.FREEZE])
			fire = true
		
		// Clear particles
		if (value[e_value.CLEAR])
			particle_spawner_clear()
	}
}

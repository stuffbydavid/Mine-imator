/// tl_update_values()
/// @desc Updates the values.

var oldkf = keyframe_current;
keyframe_current = null
keyframe_next = null

// Find keyframes
for (var k = 0; k < ds_list_size(keyframe_list); k++)
{
	keyframe_next = keyframe_list[|k]
	if (keyframe_list[|k].position > app.timeline_marker)
		break
	keyframe_current = keyframe_list[|k]
}

// Seamless region looping
var loopstart, loopend;
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

if (app.timeline_seamless_repeat && app.timeline_marker >= loopstart && app.timeline_marker < loopend)
{
	// Change keyframes so the animation is seamless
	var lastkf, loopnext, loopprev;
	lastkf = ds_list_size(keyframe_list) - 1
	loopnext = false
	loopprev = false
	
	if (keyframe_next = keyframe_current || keyframe_next.position > loopend) // Continue into the first keyframe
	{
		// Get first keyframe in timeline region
		for (var k = 0; k < ds_list_size(keyframe_list); k++)
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
		for (var k = 0; k < ds_list_size(keyframe_list); k++)
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
	var p, regionsize, easep;
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
else
{
	// Get progress
	var p = 0;
	if (keyframe_current && keyframe_next && keyframe_current != keyframe_next)
		p = (app.timeline_marker - keyframe_current.position) / (keyframe_next.position - keyframe_current.position);
}

// Transition
tl_update_values_ease(e_value.TRANSITION, "instant", 0)
var trans = value[e_value.TRANSITION];

// Position
if (value_type[e_value_type.POSITION])
{
	tl_update_values_ease(e_value.POS_X, trans, p)
	tl_update_values_ease(e_value.POS_Y, trans, p)
	tl_update_values_ease(e_value.POS_Z, trans, p)
}

// Rotation
if (value_type[e_value_type.ROTATION])
{
	tl_update_values_ease(e_value.ROT_X, trans, p)
	tl_update_values_ease(e_value.ROT_Y, trans, p)
	tl_update_values_ease(e_value.ROT_Z, trans, p)
}

// Scale
if (value_type[e_value_type.SCALE])
{
	tl_update_values_ease(e_value.SCA_X, trans, p)
	tl_update_values_ease(e_value.SCA_Y, trans, p)
	tl_update_values_ease(e_value.SCA_Z, trans, p)
}

// Bend
if (value_type[e_value_type.BEND])
{
	tl_update_values_ease(e_value.BEND_ANGLE_X, trans, p)
	tl_update_values_ease(e_value.BEND_ANGLE_Y, trans, p)
	tl_update_values_ease(e_value.BEND_ANGLE_Z, trans, p)
}

// Color
if (value_type[e_value_type.COLOR])
{
	tl_update_values_ease(e_value.ALPHA, trans, p)
	tl_update_values_ease(e_value.RGB_ADD, trans, p)
	tl_update_values_ease(e_value.RGB_SUB, trans, p)
	tl_update_values_ease(e_value.RGB_MUL, trans, p)
	tl_update_values_ease(e_value.HSB_ADD, trans, p)
	tl_update_values_ease(e_value.HSB_SUB, trans, p)
	tl_update_values_ease(e_value.HSB_MUL, trans, p)
	tl_update_values_ease(e_value.MIX_COLOR, trans, p)
	tl_update_values_ease(e_value.GLOW_COLOR, trans, p)
	tl_update_values_ease(e_value.MIX_PERCENT, trans, p)
	tl_update_values_ease(e_value.BRIGHTNESS, trans, p)
}

// Particles
if (value_type[e_value_type.PARTICLES])
{
	tl_update_values_ease(e_value.SPAWN, trans, p)
	tl_update_values_ease(e_value.FREEZE, trans, p)
	tl_update_values_ease(e_value.CLEAR, trans, p)
	tl_update_values_ease(e_value.CUSTOM_SEED, trans, p)
	tl_update_values_ease(e_value.SEED, trans, p)
	tl_update_values_ease(e_value.ATTRACTOR, trans, p)
	tl_update_values_ease(e_value.FORCE, trans, p)
}

// Light
if (value_type[e_value_type.LIGHT])
{
	tl_update_values_ease(e_value.LIGHT_COLOR, trans, p)
	tl_update_values_ease(e_value.LIGHT_RANGE, trans, p)
	tl_update_values_ease(e_value.LIGHT_FADE_SIZE, trans, p)
	
	// Spotlight
	if (value_type[e_value_type.SPOTLIGHT])
	{
		tl_update_values_ease(e_value.LIGHT_SPOT_RADIUS, trans, p)
		tl_update_values_ease(e_value.LIGHT_SPOT_SHARPNESS, trans, p)
	}
}

// Camera
if (value_type[e_value_type.CAMERA])
{
	tl_update_values_ease(e_value.CAM_FOV, trans, p)
	
	tl_update_values_ease(e_value.CAM_ROTATE, trans, p)
	tl_update_values_ease(e_value.CAM_ROTATE_DISTANCE, trans, p)
	tl_update_values_ease(e_value.CAM_ROTATE_ANGLE_XY, trans, p)
	tl_update_values_ease(e_value.CAM_ROTATE_ANGLE_Z, trans, p)
	
	tl_update_values_ease(e_value.CAM_SHAKE, trans, p)
	tl_update_values_ease(e_value.CAM_SHAKE_VERTICAL_OFFSET, trans, p)
	tl_update_values_ease(e_value.CAM_SHAKE_VERTICAL_SPEED, trans, p)
	tl_update_values_ease(e_value.CAM_SHAKE_VERTICAL_STRENGTH, trans, p)
	tl_update_values_ease(e_value.CAM_SHAKE_HORIZONTAL_OFFSET, trans, p)
	tl_update_values_ease(e_value.CAM_SHAKE_HORIZONTAL_SPEED, trans, p)
	tl_update_values_ease(e_value.CAM_SHAKE_HORIZONTAL_STRENGTH, trans, p)
	
	tl_update_values_ease(e_value.CAM_DOF, trans, p)
	tl_update_values_ease(e_value.CAM_DOF_DEPTH, trans, p)
	tl_update_values_ease(e_value.CAM_DOF_RANGE, trans, p)
	tl_update_values_ease(e_value.CAM_DOF_FADE_SIZE, trans, p)
	tl_update_values_ease(e_value.CAM_DOF_BLUR_SIZE, trans, p)
	tl_update_values_ease(e_value.CAM_DOF_FRINGE, trans, p)
	tl_update_values_ease(e_value.CAM_DOF_FRINGE_ANGLE_RED, trans, p)
	tl_update_values_ease(e_value.CAM_DOF_FRINGE_ANGLE_GREEN, trans, p)
	tl_update_values_ease(e_value.CAM_DOF_FRINGE_ANGLE_BLUE, trans, p)
	tl_update_values_ease(e_value.CAM_DOF_FRINGE_RED, trans, p)
	tl_update_values_ease(e_value.CAM_DOF_FRINGE_GREEN, trans, p)
	tl_update_values_ease(e_value.CAM_DOF_FRINGE_BLUE, trans, p)
	
	tl_update_values_ease(e_value.CAM_BLOOM, trans, p)
	tl_update_values_ease(e_value.CAM_BLOOM_THRESHOLD, trans, p)
	tl_update_values_ease(e_value.CAM_BLOOM_INTENSITY, trans, p)
	tl_update_values_ease(e_value.CAM_BLOOM_RADIUS, trans, p)
	tl_update_values_ease(e_value.CAM_BLOOM_RATIO, trans, p)
	tl_update_values_ease(e_value.CAM_BLOOM_BLEND, trans, p)
	
	tl_update_values_ease(e_value.CAM_LENS_DIRT, trans, p)
	tl_update_values_ease(e_value.TEXTURE_OBJ, trans, p)
	tl_update_values_ease(e_value.CAM_LENS_DIRT_BLOOM, trans, p)
	tl_update_values_ease(e_value.CAM_LENS_DIRT_GLOW, trans, p)
	tl_update_values_ease(e_value.CAM_LENS_DIRT_RADIUS, trans, p)
	tl_update_values_ease(e_value.CAM_LENS_DIRT_INTENSITY, trans, p)
	tl_update_values_ease(e_value.CAM_LENS_DIRT_POWER, trans, p)
	
	tl_update_values_ease(e_value.CAM_COLOR_CORRECTION, trans, p)
	tl_update_values_ease(e_value.CAM_CONTRAST, trans, p)
	tl_update_values_ease(e_value.CAM_BRIGHTNESS, trans, p)
	tl_update_values_ease(e_value.CAM_SATURATION, trans, p)
	tl_update_values_ease(e_value.CAM_VIBRANCE, trans, p)
	tl_update_values_ease(e_value.CAM_COLOR_BURN, trans, p)
	
	tl_update_values_ease(e_value.CAM_GRAIN, trans, p)
	tl_update_values_ease(e_value.CAM_GRAIN_STRENGTH, trans, p)
	tl_update_values_ease(e_value.CAM_GRAIN_SATURATION, trans, p)
	tl_update_values_ease(e_value.CAM_GRAIN_SIZE, trans, p)
	
	tl_update_values_ease(e_value.CAM_VIGNETTE, trans, p)
	tl_update_values_ease(e_value.CAM_VIGNETTE_RADIUS, trans, p)
	tl_update_values_ease(e_value.CAM_VIGNETTE_SOFTNESS, trans, p)
	tl_update_values_ease(e_value.CAM_VIGNETTE_STRENGTH, trans, p)
	
	tl_update_values_ease(e_value.CAM_WIDTH, trans, p)
	tl_update_values_ease(e_value.CAM_HEIGHT, trans, p)
	tl_update_values_ease(e_value.CAM_SIZE_USE_PROJECT, trans, p)
	tl_update_values_ease(e_value.CAM_SIZE_KEEP_ASPECT_RATIO, trans, p)
}

// Background
if (value_type[e_value_type.BACKGROUND])
{
	tl_update_values_ease(e_value.BG_IMAGE_SHOW, trans, p)
	tl_update_values_ease(e_value.BG_SKY_MOON_PHASE, trans, p)
	tl_update_values_ease(e_value.BG_SKY_TIME, trans, p)
	tl_update_values_ease(e_value.BG_SKY_ROTATION, trans, p)
	tl_update_values_ease(e_value.BG_SUNLIGHT_RANGE, trans, p)
	tl_update_values_ease(e_value.BG_SUNLIGHT_FOLLOW, trans, p)
	tl_update_values_ease(e_value.BG_SUNLIGHT_STRENGTH, trans, p)
	tl_update_values_ease(e_value.BG_DESATURATE_NIGHT, trans, p)
	tl_update_values_ease(e_value.BG_DESATURATE_NIGHT_AMOUNT, trans, p)
	tl_update_values_ease(e_value.BG_SKY_CLOUDS_SHOW, trans, p)
	tl_update_values_ease(e_value.BG_SKY_CLOUDS_SPEED, trans, p)
	tl_update_values_ease(e_value.BG_SKY_CLOUDS_Z, trans, p)
	tl_update_values_ease(e_value.BG_SKY_CLOUDS_OFFSET, trans, p)
	tl_update_values_ease(e_value.BG_GROUND_SHOW, trans, p)
	tl_update_values_ease(e_value.BG_SKY_COLOR, trans, p)
	tl_update_values_ease(e_value.BG_SKY_CLOUDS_COLOR, trans, p)
	tl_update_values_ease(e_value.BG_SUNLIGHT_COLOR, trans, p)
	tl_update_values_ease(e_value.BG_AMBIENT_COLOR, trans, p)
	tl_update_values_ease(e_value.BG_NIGHT_COLOR, trans, p)
	tl_update_values_ease(e_value.BG_GRASS_COLOR, trans, p)
	tl_update_values_ease(e_value.BG_FOLIAGE_COLOR, trans, p)
	tl_update_values_ease(e_value.BG_WATER_COLOR, trans, p)
	tl_update_values_ease(e_value.BG_FOG_SHOW, trans, p)
	tl_update_values_ease(e_value.BG_FOG_SKY, trans, p)
	tl_update_values_ease(e_value.BG_FOG_CUSTOM_COLOR, trans, p)
	tl_update_values_ease(e_value.BG_FOG_COLOR, trans, p)
	tl_update_values_ease(e_value.BG_FOG_CUSTOM_OBJECT_COLOR, trans, p)
	tl_update_values_ease(e_value.BG_FOG_OBJECT_COLOR, trans, p)
	tl_update_values_ease(e_value.BG_FOG_DISTANCE, trans, p)
	tl_update_values_ease(e_value.BG_FOG_SIZE, trans, p)
	tl_update_values_ease(e_value.BG_FOG_HEIGHT, trans, p)
	tl_update_values_ease(e_value.BG_WIND, trans, p)
	tl_update_values_ease(e_value.BG_WIND_STRENGTH, trans, p)
	tl_update_values_ease(e_value.BG_WIND_SPEED, trans, p)
	tl_update_values_ease(e_value.BG_TEXTURE_ANI_SPEED, trans, p)
}

// Texture
if (value_type[e_value_type.TEXTURE])
	tl_update_values_ease(e_value.TEXTURE_OBJ, trans, p)
	
// Sound
if (value_type[e_value_type.SOUND])
{
	tl_update_values_ease(e_value.SOUND_OBJ, trans, p)
	tl_update_values_ease(e_value.SOUND_VOLUME, trans, p)
	tl_update_values_ease(e_value.SOUND_START, trans, p)
	tl_update_values_ease(e_value.SOUND_END, trans, p)
}

// Text
if (value_type[e_value_type.TEXT])
{
	tl_update_values_ease(e_value.TEXT, trans, p)
	tl_update_values_ease(e_value.TEXT_FONT, trans, p)
}

// Item
if (value_type[e_value_type.ITEM])
{
	tl_update_values_ease(e_value.CUSTOM_ITEM_SLOT, trans, p)
	tl_update_values_ease(e_value.ITEM_SLOT, trans, p)
	tl_update_values_ease(e_value.TEXTURE_OBJ, trans, p)
}

// Visible
tl_update_values_ease(e_value.VISIBLE, trans, p)

// Play sounds
if (type = e_tl_type.AUDIO && !hide && app.timeline_marker > app.timeline_marker_previous && app.timeline_playing)
{
	// Play new sound
	if (keyframe_current)
	{
		if (value[e_value.SOUND_OBJ] && value[e_value.SOUND_OBJ].ready && oldkf != keyframe_current)
		{
			keyframe_current.sound_play_index = audio_play_sound(value[e_value.SOUND_OBJ].sound_index, 0, true);
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
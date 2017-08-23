/// tl_update_values()
/// @desc Updates the values.

var oldkf, trans, p;

oldkf = keyframe_current
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

// Get progress
p = 0
if (keyframe_current && keyframe_next && keyframe_current != keyframe_next)
	p = (app.timeline_marker - keyframe_current.position) / (keyframe_next.position - keyframe_current.position);

// Transition
if (keyframe_current)
	value[TRANSITION] = keyframe_current.value[TRANSITION]

trans = transition_list[|value[TRANSITION]]

// Position
if (value_type[POSITION])
{
	tl_update_values_ease(XPOS, trans, p)
	tl_update_values_ease(YPOS, trans, p)
	tl_update_values_ease(ZPOS, trans, p)
}

// Rotation
if (value_type[ROTATION])
{
	tl_update_values_ease(XROT, trans, p)
	tl_update_values_ease(YROT, trans, p)
	tl_update_values_ease(ZROT, trans, p)
}

// Scale
if (value_type[SCALE])
{
	tl_update_values_ease(XSCA, trans, p)
	tl_update_values_ease(YSCA, trans, p)
	tl_update_values_ease(ZSCA, trans, p)
}

// Bend
if (value_type[BEND])
	tl_update_values_ease(BENDANGLE, trans, p)
	
// Color
if (value_type[COLOR])
{
	tl_update_values_ease(ALPHA, trans, p)
	tl_update_values_ease(RGBADD, trans, p)
	tl_update_values_ease(RGBSUB, trans, p)
	tl_update_values_ease(RGBMUL, trans, p)
	tl_update_values_ease(HSBADD, trans, p)
	tl_update_values_ease(HSBSUB, trans, p)
	tl_update_values_ease(HSBMUL, trans, p)
	tl_update_values_ease(MIXCOLOR, trans, p)
	tl_update_values_ease(MIXPERCENT, trans, p)
	tl_update_values_ease(BRIGHTNESS, trans, p)
}

// Particles
if (value_type[PARTICLES])
{
	tl_update_values_ease(SPAWN, trans, p)
	tl_update_values_ease(ATTRACTOR, trans, p)
	tl_update_values_ease(FORCE, trans, p)
}

// Light
if (value_type[LIGHT])
{
	tl_update_values_ease(LIGHTCOLOR, trans, p)
	tl_update_values_ease(LIGHTRANGE, trans, p)
	tl_update_values_ease(LIGHTFADESIZE, trans, p)
	
	// Spotlight
	if (value_type[SPOTLIGHT])
	{
		tl_update_values_ease(LIGHTSPOTRADIUS, trans, p)
		tl_update_values_ease(LIGHTSPOTSHARPNESS, trans, p)
	}
}

// Camera
if (value_type[CAMERA])
{
	tl_update_values_ease(CAMFOV, trans, p)
	tl_update_values_ease(CAMROTATE, trans, p)
	tl_update_values_ease(CAMROTATEDISTANCE, trans, p)
	tl_update_values_ease(CAMROTATEXYANGLE, trans, p)
	tl_update_values_ease(CAMROTATEZANGLE, trans, p)
	tl_update_values_ease(CAMDOF, trans, p)
	tl_update_values_ease(CAMDOFDEPTH, trans, p)
	tl_update_values_ease(CAMDOFRANGE, trans, p)
	tl_update_values_ease(CAMDOFFADESIZE, trans, p)
	tl_update_values_ease(CAMWIDTH, trans, p)
	tl_update_values_ease(CAMHEIGHT, trans, p)
	tl_update_values_ease(CAMSIZEUSEPROJECT, trans, p)
	tl_update_values_ease(CAMSIZEKEEPASPECTRATIO, trans, p)
}

// Background
if (value_type[BACKGROUND])
{
	tl_update_values_ease(BGSKYMOONPHASE, trans, p)
	tl_update_values_ease(BGSKYTIME, trans, p)
	tl_update_values_ease(BGSKYROTATION, trans, p)
	tl_update_values_ease(BGSKYCLOUDSSPEED, trans, p)
	tl_update_values_ease(BGSKYCOLOR, trans, p)
	tl_update_values_ease(BGSKYCLOUDSCOLOR, trans, p)
	tl_update_values_ease(BGSUNLIGHTCOLOR, trans, p)
	tl_update_values_ease(BGAMBIENTCOLOR, trans, p)
	tl_update_values_ease(BGNIGHTCOLOR, trans, p)
	tl_update_values_ease(BGFOGCOLOR, trans, p)
	tl_update_values_ease(BGFOGDISTANCE, trans, p)
	tl_update_values_ease(BGFOGSIZE, trans, p)
	tl_update_values_ease(BGFOGHEIGHT, trans, p)
	tl_update_values_ease(BGWINDSTRENGTH, trans, p)
	tl_update_values_ease(BGWINDSPEED, trans, p)
	tl_update_values_ease(BGTEXTUREANISPEED, trans, p)
}

// Texture
if (value_type[TEXTURE])
	tl_update_values_ease(TEXTUREOBJ, trans, p)
	
// Sound
if (value_type[SOUND])
{
	tl_update_values_ease(SOUNDOBJ, trans, p)
	tl_update_values_ease(SOUNDVOLUME, trans, p)
	tl_update_values_ease(SOUNDSTART, trans, p)
	tl_update_values_ease(SOUNDEND, trans, p)
}

// Visible
tl_update_values_ease(VISIBLE, trans, p)

// Play sounds
if (type = "audio" && !hide && app.timeline_marker > app.timeline_marker_previous && app.timeline_playing)
{
	// Play new sound
	if (keyframe_current)
	{
		if (value[SOUNDOBJ] && value[SOUNDOBJ].ready && oldkf != keyframe_current)
		{
			keyframe_current.sound_play_index = audio_play_sound(value[SOUNDOBJ].sound_index, 0, true);
			audio_sound_set_track_position(keyframe_current.sound_play_index, value[SOUNDSTART] mod (value[SOUNDOBJ].sound_samples / sample_rate))
			audio_sound_gain(keyframe_current.sound_play_index, value[SOUNDVOLUME], 0)
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
				
			if (timeline.keyframe_current = keyframe_list[|k])
				break
		}
	}
}

// Fire particles
if (type = "particles" && !temp.pc_spawn_constant && value[SPAWN] && app.timeline_marker > app.timeline_marker_previous && oldkf != keyframe_current)
	fire = true

/// tl_keyframe_save(keyframe)
/// @arg keyframe

var kf = argument0;

if (kf.value[e_value.ATTRACTOR] != null)
	with (kf.value[e_value.ATTRACTOR])
		tl_save()
	
if (kf.value[e_value.TEXTURE_OBJ] != null)
{
	kf.value[e_value.TEXTURE_OBJ].save = true
	
	// Camera used as texture
	if (kf.value[e_value.ATTRACTOR].type = "camera")
		with (kf.value[e_value.ATTRACTOR])
			tl_save()
}

if (kf.value[e_value.SOUND_OBJ] != null)
	kf.value[e_value.SOUND_OBJ].save = true

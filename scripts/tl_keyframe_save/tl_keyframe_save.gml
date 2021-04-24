/// tl_keyframe_save(keyframe)
/// @arg keyframe

function tl_keyframe_save(kf)
{
	if (kf.value[e_value.ATTRACTOR] != null)
		with (kf.value[e_value.ATTRACTOR])
			tl_save()
	
	if (kf.value[e_value.TEXTURE_OBJ] > 0)
	{
		kf.value[e_value.TEXTURE_OBJ].save = true
		
		// Camera used as texture
		if (kf.value[e_value.TEXTURE_OBJ].type = e_tl_type.CAMERA)
			with (kf.value[e_value.TEXTURE_OBJ])
				tl_save()
	}
	
	if (kf.value[e_value.SOUND_OBJ] != null)
		kf.value[e_value.SOUND_OBJ].save = true
	
	if (kf.value[e_value.TEXT_FONT] != null)
		kf.value[e_value.TEXT_FONT].save = true
}

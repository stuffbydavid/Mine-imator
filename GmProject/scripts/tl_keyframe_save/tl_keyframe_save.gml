/// tl_keyframe_save(keyframe)
/// @arg keyframe

function tl_keyframe_save(kf)
{
	if (kf.value[e_value.PATH_OBJ] != null)
		with (kf.value[e_value.PATH_OBJ])
			tl_save()
	
	if (kf.value[e_value.ATTRACTOR] != null)
		with (kf.value[e_value.ATTRACTOR])
			tl_save()
	
	if (kf.value[e_value.IK_TARGET] != null)
		with (kf.value[e_value.IK_TARGET])
			tl_save()
	
	if (kf.value[e_value.IK_TARGET_ANGLE] != null)
		with (kf.value[e_value.IK_TARGET_ANGLE])
			tl_save()
	
	if (kf.value[e_value.TEXTURE_OBJ] > 0)
	{
		kf.value[e_value.TEXTURE_OBJ].save = true
		
		// Camera used as texture
		if (kf.value[e_value.TEXTURE_OBJ].type = e_tl_type.CAMERA)
			with (kf.value[e_value.TEXTURE_OBJ])
				tl_save()
	}
	
	if (kf.value[e_value.TEXTURE_MATERIAL_OBJ] > 0)
		kf.value[e_value.TEXTURE_MATERIAL_OBJ].save = true
	
	if (kf.value[e_value.TEXTURE_NORMAL_OBJ] > 0)
		kf.value[e_value.TEXTURE_NORMAL_OBJ].save = true
	
	if (kf.value[e_value.SOUND_OBJ] != null)
		kf.value[e_value.SOUND_OBJ].save = true
	
	if (kf.value[e_value.TEXT_FONT] != null)
		kf.value[e_value.TEXT_FONT].save = true
}

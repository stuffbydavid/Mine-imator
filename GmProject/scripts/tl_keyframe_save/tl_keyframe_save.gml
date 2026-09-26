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
	
	var tex;
	tex = res_eval(kf.value[e_value.TEXTURE_OBJ])
	if (tex != null && instance_exists(tex))
	{
		tex.save = true
		
		// Camera used as texture
		if (tex.type = e_tl_type.CAMERA)
			with (tex)
			tl_save()
	}
	
	tex = res_eval(kf.value[e_value.TEXTURE_MATERIAL_OBJ])
	if (tex != null && instance_exists(tex))
		tex.save = true
	
	tex = res_eval(kf.value[e_value.TEXTURE_NORMAL_OBJ])
	if (tex != null && instance_exists(tex))
		tex.save = true
	
	tex = kf.value[e_value.SOUND_OBJ]
	if (tex != null && instance_exists(tex))
		tex.save = true
	
	tex = res_eval(kf.value[e_value.TEXT_FONT])
	if (tex != null && instance_exists(tex))
		tex.save = true
}

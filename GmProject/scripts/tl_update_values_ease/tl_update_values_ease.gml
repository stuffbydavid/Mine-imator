/// @arg valueid

function tl_update_values_ease(vid, cachechannel = false)
{
	var oldval, curval, nextval, val;
	oldval = value[vid]
	
	if (keyframe_animate)
	{
		curval = keyframe_current.value[vid]
		nextval = keyframe_next.value[vid]
		
		if (cachechannel && curval != nextval)
			array_push(keyframe_value_cache_channels, vid)

		if ((oldval = curval) && (oldval = nextval))
			return false
		
		val = tl_value_interpolate(vid, keyframe_progress_ease, curval, nextval)
	}
	else if (keyframe_next)
		val = keyframe_next.value[vid]
	else
		val = value_default[vid]
	
	if (oldval != val)
	{
		// Keep explicit update_matrix callers as conservative full invalidations
		var updateflags = e_tl_update.LOCAL;
		if (vid >= e_value.POS_X && vid <= e_value.BEND_ANGLE_Z)
		{
			updateflags = e_tl_update.TRANSFORM
			if (vid >= e_value.SCA_X && vid <= e_value.SCA_Z)
				updateflags = updateflags | e_tl_update.SCALE
			else if (vid >= e_value.BEND_ANGLE_LEGACY)
				updateflags = e_tl_update.BEND
		}
		else if (vid >= e_value.PATH_OBJ && vid <= e_value.IK_ANGLE_OFFSET)
		{
			updateflags = e_tl_update.TRANSFORM
			if (vid >= e_value.IK_TARGET)
				updateflags = updateflags | e_tl_update.BEND
		}
		else if (vid >= e_value.CAM_ROTATE && vid <= e_value.CAM_ROTATE_ANGLE_Z)
			updateflags = e_tl_update.TRANSFORM
		
		else if ((vid >= e_value.ALPHA && vid <= e_value.WIND_INFLUENCE) ||
				 (vid >= e_value.TEXTURE_OBJ && vid <= e_value.TEXTURE_NORMAL_OBJ) || vid = e_value.VISIBLE)
			updateflags = e_tl_update.APPEARANCE
		
		else if (!((vid >= e_value.SPAWN && vid <= e_value.CAM_HEIGHT) ||
				   (vid >= e_value.CAM_FX_SHAKE_MODE && vid <= e_value.ENV_BRIGHTNESS) ||
				   (vid >= e_value.SOUND_OBJ && vid <= e_value.ITEM_NAME) ||
				   (vid >= e_value.TRANSITION && vid <= e_value.EASE_OUT_Y)))
			updateflags = e_tl_update.ALL

		update_value_flags = update_value_flags | updateflags
		value[vid] = val
		
		return true
	}
	
	return false
}

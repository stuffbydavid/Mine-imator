/// @arg valueid

function tl_update_values_ease(vid)
{
	var oldval, curval, nextval, val;
	oldval = value[vid]
	
	if (keyframe_animate)
	{
		curval = keyframe_current.value[vid]
		nextval = keyframe_next.value[vid]
		
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
		var dirtyflags = e_tl_dirty.LOCAL;
		if (vid >= e_value.POS_X && vid <= e_value.BEND_ANGLE_Z)
		{
			dirtyflags = e_tl_dirty.TRANSFORM
			if (vid >= e_value.SCA_X && vid <= e_value.SCA_Z)
				dirtyflags = dirtyflags | e_tl_dirty.SCALE
			else if (vid >= e_value.BEND_ANGLE_LEGACY)
				dirtyflags = e_tl_dirty.BEND
		}
		else if (vid >= e_value.PATH_OBJ && vid <= e_value.IK_ANGLE_OFFSET)
		{
			dirtyflags = e_tl_dirty.TRANSFORM
			if (vid >= e_value.IK_TARGET)
				dirtyflags = dirtyflags | e_tl_dirty.BEND
		}
		else if (vid >= e_value.CAM_ROTATE && vid <= e_value.CAM_ROTATE_ANGLE_Z)
			dirtyflags = e_tl_dirty.TRANSFORM
		else if ((vid >= e_value.ALPHA && vid <= e_value.WIND_INFLUENCE) ||
				 (vid >= e_value.TEXTURE_OBJ && vid <= e_value.TEXTURE_NORMAL_OBJ) || vid = e_value.VISIBLE)
			dirtyflags = e_tl_dirty.APPEARANCE
		else if (!((vid >= e_value.SPAWN && vid <= e_value.CAM_HEIGHT) ||
				   (vid >= e_value.CAM_FX_SHAKE_MODE && vid <= e_value.ENV_BRIGHTNESS) ||
				   (vid >= e_value.SOUND_OBJ && vid <= e_value.ITEM_NAME) ||
				   (vid >= e_value.TRANSITION && vid <= e_value.EASE_OUT_Y)))
			dirtyflags = e_tl_dirty.ALL

		update_value_flags = update_value_flags | dirtyflags
		value[vid] = val
		return true
	}
	
	return false
}

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
		update_matrix = true
		value[vid] = val
		return true
	}
	
	return false
}

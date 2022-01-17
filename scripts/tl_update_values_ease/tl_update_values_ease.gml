/// tl_update_values_ease(valueid, [progress])
/// @arg valueid
/// @arg [progress]

function tl_update_values_ease(vid, progress = keyframe_progress_ease)
{
	var oldval, curval, nextval, val;
	oldval = value[vid]
	
	if (keyframe_animate)
	{
		curval = keyframe_current_values[vid]
		nextval = keyframe_next_values[vid]
		
		if ((oldval = curval) && (oldval = nextval))
			return 0
		
		val = tl_value_interpolate(vid, progress, curval, nextval)
	}
	else if (keyframe_next)
		val = keyframe_next_values[vid]
	else
		val = value_default[vid]
	
	if (oldval != val)
	{
		update_matrix = true
		value[vid] = val
	}
}

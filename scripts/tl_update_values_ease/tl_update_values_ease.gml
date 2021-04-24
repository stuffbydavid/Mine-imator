/// tl_update_values_ease(valueid, transition, percent)
/// @arg valueid
/// @arg transition
/// @arg percent

function tl_update_values_ease(vid, trans, p)
{
	var val;
	
	if (keyframe_current != null && keyframe_next != null && keyframe_current != keyframe_next)
		val = tl_value_interpolate(vid, ease(trans, p), keyframe_current.value[vid], keyframe_next.value[vid])
	else if (keyframe_next != null)
		val = keyframe_next.value[vid]
	else
		val = value_default[vid]
	
	if (value[vid] != val)
		update_matrix = true
	
	value[vid] = val
}

/// tl_keyframes_stretch(pivot, stretch)
/// @arg pivot
/// @arg stretch
/// @desc Sets the new position of each selected keyframe, scaled around a frame. Keeps every timeline's keyframes in order.

function tl_keyframes_stretch(pivot, stretch)
{
	var prevpos, kf;
	
	with (obj_timeline)
	{
		prevpos = null
		
		for (var k = 0; k < ds_list_size(keyframe_list); k++)
		{
			kf = keyframe_list[|k]
			
			if (!kf.selected)
				continue
			
			kf.new_position = max(0, round(pivot + (kf.move_pos - pivot) * stretch))
			
			if (prevpos != null)
				kf.new_position = max(kf.new_position, prevpos + 1)
			
			prevpos = kf.new_position
		}
	}
}

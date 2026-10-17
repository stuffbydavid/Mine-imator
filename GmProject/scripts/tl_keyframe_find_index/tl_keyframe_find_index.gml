/// @desc Finds the first keyframe at or after a position, or the list size if none exists.
/// @arg position
/// @arg [strictly_after]

function tl_keyframe_find_index(markerpos, strictlyafter = false)
{
	var low, high;
	low = 0
	high = ds_list_size(keyframe_list)

	while (low < high)
	{
		var mid, pos;
		mid = floor((low + high) / 2)
		pos = keyframe_list[|mid].position

		if (pos < markerpos || (strictlyafter && pos = markerpos))
			low = mid + 1
		else
			high = mid
	}

	return low
}

/// action_tl_keyframes_sound_resize_done()

with (obj_timeline)
	updatevalues = false
	
if (history_undo)
{
	with (history_data) 
	{
		var new_index = kf_resize_new_index;
		for (var k = 0; k < kf_resize_amount; k++) // Move back keyframes
		{
			with (iid_find(kf_resize_tl[k]).keyframe[new_index[k]])
			{
				newpos = other.kf_resize_old_pos[k]
				if (pos = newpos)
					continue
				
				value[SOUNDSTART] = other.kf_resize_old_start[k]
			
				with (tl)
				{
					tl_keyframes_pushup(other.index)
					updatevalues = true
				}
				
				for (var a = 0; a < other.kf_resize_amount; a++)  // Push down other indices of same timeline
					if (iid_find(other.kf_resize_tl[a]) = tl && new_index[a] > index)
						new_index[a]--
			}
		}
	}
}
else if (history_redo)
{
	with (history_data)
	{
		var old_index = kf_resize_old_index;
		for (var k = 0; k < kf_resize_amount; k++) // Move forward keyframes
		{
			with (iid_find(kf_resize_tl[k]).keyframe[old_index[k]])
			{
				newpos = other.kf_resize_new_pos[k]
				if (pos = newpos)
					continue
					
				value[SOUNDSTART] = other.kf_resize_new_start[k]
			
				with (tl)
				{
					tl_keyframes_pushup(other.index)
					updatevalues = true
				}
				
				for (var a = 0; a < other.kf_resize_amount; a++)  // Push down other indices of same timeline
					if (iid_find(other.kf_resize_tl[a]) = tl && old_index[a] > index)
						old_index[a]--
			}
		}
	}
}
else
{
	with (history_set(action_tl_keyframes_sound_resize_done))
	{
		kf_resize_amount = 0
		with (obj_keyframe)
		{
			if (!select || soundresizeindex < 0)
				continue
				
			other.kf_resize_tl[other.kf_resize_amount] = iid_get(tl)
			other.kf_resize_old_index[other.kf_resize_amount] = soundresizeindex
			other.kf_resize_old_pos[other.kf_resize_amount] = soundresizepos
			other.kf_resize_old_start[other.kf_resize_amount] = soundresizestart
			other.kf_resize_new_index[other.kf_resize_amount] = index
			other.kf_resize_new_pos[other.kf_resize_amount] = pos
			other.kf_resize_new_start[other.kf_resize_amount] = value[SOUNDSTART]
			other.kf_resize_amount++
			tl.updatevalues = true
		}
	}
	window_busy = ""
}

if (history_undo || history_redo)
{
	with (obj_keyframe)
	{
		if (!select || pos = newpos)
			continue
		
		with (tl)
			tl_keyframe_add(other.newpos, other.id)
	}
}

tl_update_length()

with (obj_timeline)
	if (updatevalues)
		tl_update_values()

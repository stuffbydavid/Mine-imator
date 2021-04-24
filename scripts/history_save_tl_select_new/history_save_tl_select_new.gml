/// history_save_tl_select_new()
/// @desc Saves the newly selected timelines in the history object.

function history_save_tl_select_new()
{
	tl_sel_new_amount = 0
	with (obj_timeline)
	{
		if (!selected)
			continue
		
		other.tl_sel_new_save_id[other.tl_sel_new_amount] = save_id
		other.tl_sel_new_kf_amount[other.tl_sel_new_amount] = 0
		
		for (var k = 0; k < ds_list_size(keyframe_list); k++)
		{
			var kf = keyframe_list[|k];
			if (!kf.selected)
				continue
			
			other.tl_sel_new_kf_index[other.tl_sel_new_amount, other.tl_sel_new_kf_amount[other.tl_sel_new_amount]] = k
			other.tl_sel_new_kf_amount[other.tl_sel_new_amount]++
		}
		
		other.tl_sel_new_amount++
	}
}

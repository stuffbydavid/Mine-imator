/// history_save_tl_select()
/// @desc Saves the selected timelines in the history object.

tl_sel_amount = 0

with (obj_timeline)
{
	if (!selected)
		continue
		
	other.tl_sel_save_id[other.tl_sel_amount] = save_id
	other.tl_sel_kf_amount[other.tl_sel_amount] = 0
	
	for (var k = 0; k < ds_list_size(keyframe_list); k++)
	{
		var kf = keyframe_list[|k];
		if (!kf.selected)
			continue
			
		other.tl_sel_kf_index[other.tl_sel_amount, other.tl_sel_kf_amount[other.tl_sel_amount]] = k
		other.tl_sel_kf_amount[other.tl_sel_amount]++
	}
	
	other.tl_sel_amount++
}

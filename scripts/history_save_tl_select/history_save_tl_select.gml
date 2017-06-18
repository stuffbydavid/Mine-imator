/// history_save_tl_select()
/// @desc Saves the selected timelines in the history object.

tl_sel_amount = 0
with (obj_timeline)
{
	if (!select)
		continue
		
	other.tl_sel[other.tl_sel_amount] = iid
	other.tl_sel_kf_amount[other.tl_sel_amount] = 0
	
	for (var k = 0; k < keyframe_amount; k++)
	{
		var kf = keyframe[k];
		if (!kf.select)
			continue
			
		other.tl_sel_kf[other.tl_sel_amount, other.tl_sel_kf_amount[other.tl_sel_amount]] = k
		other.tl_sel_kf_amount[other.tl_sel_amount]++
	}
	other.tl_sel_amount++
}

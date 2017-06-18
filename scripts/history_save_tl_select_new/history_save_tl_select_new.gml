/// history_save_tl_select_new()
/// @desc Saves the newly selected timelines in the history object.

tl_sel_new_amount = 0
with (obj_timeline)
{
    if (!select)
        continue
		
    other.tl_sel_new[other.tl_sel_new_amount] = iid
    other.tl_sel_new_kf_amount[other.tl_sel_new_amount] = 0
	
    for (var k = 0; k < keyframe_amount; k++)
	{
        var kf = keyframe[k];
        if (!kf.select)
            continue
			
        other.tl_sel_new_kf[other.tl_sel_new_amount, other.tl_sel_new_kf_amount[other.tl_sel_new_amount]] = k
        other.tl_sel_new_kf_amount[other.tl_sel_new_amount]++
    }
    other.tl_sel_new_amount++
}

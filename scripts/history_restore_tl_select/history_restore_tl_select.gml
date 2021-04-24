/// history_restore_tl_select()
/// @desc Restores the previously selected timelines and keyframes.

function history_restore_tl_select()
{
	tl_deselect_all()
	
	for (var t = 0; t < tl_sel_amount; t++)
	{
		with (save_id_find(tl_sel_save_id[t]))
		{
			tl_select()
			for (var k = 0; k < other.tl_sel_kf_amount[t]; k++)
				tl_keyframe_select(keyframe_list[|other.tl_sel_kf_index[t, k]])
		}
	}
}

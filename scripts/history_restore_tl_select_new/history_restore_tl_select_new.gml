/// history_restore_tl_select_new()
/// @desc Restores the previously selected timelines and keyframes.

tl_deselect_all()

for (var t = 0; t < tl_sel_new_amount; t++)
{
	with (iid_find(tl_sel_new[t]))
	{
		tl_select()
		for (var k = 0; k < other.tl_sel_new_kf_amount[t]; k++)
			tl_keyframe_select(keyframe[other.tl_sel_new_kf[t, k]])
	}
}

/// history_restore_tl_select()
/// @desc Restores the previously selected timelines and keyframes.

tl_deselect_all()

for (var t = 0; t < tl_sel_amount; t++)
{
	with (iid_find(tl_sel[t]))
	{
		tl_select()
		for (var k = 0; k < other.tl_sel_kf_amount[t]; k++)
			tl_keyframe_select(keyframe[other.tl_sel_kf[t, k]])
	}
}

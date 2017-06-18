/// history_save_keyframes()
/// @desc Saves the selected keyframe_amount in memory.

save_kf_amount = 0
with (obj_keyframe)
{
	if (!select)
		continue
		
	other.save_kf_tl[other.save_kf_amount] = iid_get(tl)
	other.save_kf_pos[other.save_kf_amount] = pos
	
	for (var v = 0; v < values; v++)
		other.save_kf_value[other.save_kf_amount, v] = tl_value_save(v, value[v])
	other.save_kf_amount++
}

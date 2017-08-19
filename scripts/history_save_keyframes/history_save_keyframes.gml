/// history_save_keyframes()
/// @desc Saves the selected keyframes in memory.

save_kf_amount = 0

with (obj_keyframe)
{
	if (!selected)
		continue
		
	other.save_kf_tl_save_id[other.save_kf_amount] = save_id_get(timeline)
	other.save_kf_pos[other.save_kf_amount] = position
	
	for (var v = 0; v < values; v++)
		other.save_kf_value[other.save_kf_amount, v] = tl_value_save(v, value[v])
	
	other.save_kf_amount++
}

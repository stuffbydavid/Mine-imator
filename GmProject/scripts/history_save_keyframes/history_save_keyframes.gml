/// history_save_keyframes()
/// @desc Saves the selected keyframes in memory.

function history_save_keyframes()
{
	save_kf_amount = 0
	
	with (obj_keyframe)
	{
		if (!selected)
			continue
		
		other.save_kf_tl_save_id[other.save_kf_amount] = save_id_get(timeline)
		other.save_kf_pos[other.save_kf_amount] = position
		
		for (var v = 0; v < e_value.amount; v++)
			other.save_kf_value[other.save_kf_amount, v] = tl_value_get_save_id(v, value[v])
		
		other.save_kf_amount++
	}
}

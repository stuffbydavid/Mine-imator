/// history_restore_keyframes()
/// @desc Restores the saved keyframes.

function history_restore_keyframes()
{
	for (var k = 0; k < save_kf_amount; k++)
	{
		with (save_id_find(save_kf_tl_save_id[k]))
		{
			var kf = tl_keyframe_add(other.save_kf_pos[k]);
			for (var v = 0; v < e_value.amount; v++)
				kf.value[v] = tl_value_find_save_id(v, kf.value[v], other.save_kf_value[k, v])
		}
	}
}

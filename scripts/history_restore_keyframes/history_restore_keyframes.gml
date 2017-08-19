/// history_restore_keyframes()
/// @desc Restores the saved keyframes.

for (var k = 0; k < save_kf_amount; k++)
{
	with (save_id_find(save_kf_tl[k]))
	{
		var kf = tl_keyframe_add(other.save_kf_pos[k]);
		for (var v = 0; v < values; v++)
			kf.value[v] = tl_value_restore(v, kf.value[v], other.save_kf_value[k, v])
	}
}
